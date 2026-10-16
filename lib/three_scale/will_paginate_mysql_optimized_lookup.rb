# frozen_string_literal: true

module ThreeScale
  # Normal pagination uses LIMIT/OFFSET to skip rows before returning full records:
  #   SELECT widgets.* FROM widgets ORDER BY widgets.id LIMIT 50 OFFSET 10000
  #
  # The optimized lookup selects IDs for the page first, then fetches those rows.
  # The performance gain comes from the large OFFSET being paid only in a narrow
  # PK-only scan rather than in full wide-row reads.  There is no gain on page 1
  # (OFFSET 0), so the optimization is skipped there.  Note that the caller is
  # still responsible for proper indices on the filter and order columns — without
  # them the ID scan will be slow regardless of this optimization.
  #
  # It applies to paginated relations of a model with a single-column primary key,
  # without grouping, HAVING, DISTINCT, custom FROM or lock.  Relations without joins
  # also need no references and no existing CTE.  Any other relation shape uses
  # WillPaginate's usual query.  Two strategies exist:
  #
  # 1. Without joins, on MySQL 8.0+ (CTE support), a single query using a CTE:
  #      WITH will_paginate_page_ids AS (
  #        SELECT widgets.id AS widget_id FROM widgets
  #        ORDER BY widgets.id LIMIT 50 OFFSET 10000
  #      )
  #      SELECT widgets.* FROM widgets
  #      JOIN will_paginate_page_ids ON will_paginate_page_ids.widget_id = widgets.id
  #
  # 2. Split queries, used for relations with joins (and no custom SELECT, which could use
  #    the joined tables) and as the fallback when CTEs are not supported.  The joins serve
  #    only the ID scan.  The main model is the relation's `klass`, so the page is then
  #    fetched by PK alone, keeping the order of the ID scan:
  #      SELECT widgets.id FROM widgets INNER JOIN ... ORDER BY ... LIMIT 50 OFFSET 10000
  #      SELECT widgets.* FROM widgets WHERE widgets.id IN (...) ORDER BY FIELD(widgets.id, ...)
  #    Join cardinality is the caller's responsibility: the page is whatever the ID scan
  #    returned.
  #
  # Association loading: the ID scan carries no association-loading directives, so a JOIN that exists
  # only to eager load can't be relied upon to filter or order the page.  Therefore:
  # - `preload` and `includes` work on both strategies, the associations are then loaded for the
  #   page records only.
  # - `eager_load` is converted to `preload` when the relation is paginated, see EagerLoadToPreload.
  # - `includes` that AR turns into an eager load JOIN because a condition or order refers to a table
  #   that is not otherwise joined uses WillPaginate's usual query, as that JOIN selects the page.
  #
  # You can also see https://bugs.mysql.com/bug.php?id=109173
  module WillPaginateMysqlOptimizedLookup
    CTE_NAME = :will_paginate_page_ids

    # Converts `eager_load` to `preload` as soon as a relation is paginated.
    #
    # `eager_load` fetches the associations with a LEFT OUTER JOIN in the very query that selects the
    # page.  The optimized lookup can't do that: the ID scan is narrow on purpose and the page is then
    # fetched by primary key alone, so a JOIN that was added only by `eager_load` would be lost.
    # Replaying it in the ID scan is not an option either, because for a has_many it multiplies rows
    # and breaks the LIMIT/OFFSET page boundary.  A `preload` keeps the associations loaded, using
    # one extra query per association, with no N+1.
    #
    # This is also what makes the associations skippable.  API responders strip `includes` and `preload`
    # from the relation before materializing it, so that the `stale?` check doesn't wait for associations
    # that are not needed for a 304, and preload only for a stale response.  `eager_load` couldn't be
    # stripped that way, because the JOIN would be part of the page query itself.
    #
    # The consequence for callers: filtering or ordering by a column of the association is NOT satisfied
    # by `eager_load` of a paginated relation.  Add an explicit `joins` (or `includes` with `references`,
    # which uses the usual query) for it.
    module EagerLoadToPreload
      def page(num)
        relation = super
        return relation if relation.eager_load_values.empty?

        relation.preload(*relation.eager_load_values).unscope(:eager_load)
      end
    end

    def to_a
      unless loaded?
        records = optimized_lookup_records
        load_records(records) if records
      end
      super
    end

    private

    # Returns nil when the relation is not eligible, so WillPaginate's usual query is used.
    def optimized_lookup_records
      return unless optimizable_page?

      if joins_values.any? || left_outer_joins_values.any?
        # The second query has no joins, so a custom SELECT that may use joined columns can't be
        # replayed there.  This could easily be relaxed to accept a SELECT made only of symbols,
        # as AR qualifies those with the main table.
        records_via_split_queries if select_values.empty?
      else
        records_without_joins
      end
    end

    def records_without_joins
      # references forces AR into a JOIN-based load strategy, which the ID-only queries do not handle.
      return unless references_values.empty?
      # Adding our CTE to a relation that already has one risks name collisions and nested CTE scope errors.
      return unless with_values.empty?

      connection.supports_common_table_expressions? ? records_via_cte : records_via_split_queries
    end

    # :reek:NilCheck
    def optimizable_page? # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      # Only paginated relations (WillPaginate sets current_page via .paginate).
      current_page.present? &&
        # The gain comes from avoiding a full-row scan at high offsets; page 1 (OFFSET 0) is already fast.
        offset_value.positive? &&
        # A nil PK (no primary key) or an Array PK (composite key) cannot be used as a single lookup column.
        klass.primary_key.is_a?(String) &&
        # Skip when the caller already selected only the PK — a plain
        # LIMIT/OFFSET on a narrow index-only scan is already optimal.
        !(select_values.size == 1 && select_values.first.to_s == klass.primary_key) &&
        # GROUP BY changes the unit of pagination from rows to groups; the PK no longer identifies a single row.
        group_values.empty? &&
        # HAVING without GROUP BY is meaningless, and with it the pagination semantics are already broken (see above).
        having_clause.empty? &&
        # DISTINCT deduplicates before LIMIT/OFFSET, making the ID list potentially wrong after the lookup.
        !distinct_value &&
        # A custom FROM (alias, subquery, index hint) breaks the table reference the lookup relies on.
        from_clause.empty? &&
        # Locking requires atomicity across the whole fetch; splitting it into phases breaks that.
        lock_value.nil? &&
        # EagerLoadToPreload converts `eager_load` on paginate, so only an `eager_load` added afterwards
        # gets here.  Its JOIN can't be replayed in the ID scan, so leave such relations to the usual query.
        eager_load_values.empty? &&
        # `includes` that AR loads with a JOIN because a condition or order refers to a table that is not
        # otherwise joined: that JOIN selects the page, but the ID scan doesn't carry it.
        !(includes_values.any? && send(:references_eager_loaded_tables?))
    end

    def records_via_cte
      primary_key = klass.primary_key
      ordered_relation = order_values.empty? ? order(primary_key) : self

      # reselect replaces any caller-supplied SELECT with just the PK alias so the CTE stays a
      # narrow, index-only scan regardless of what the outer query selects.  Aggregate expressions
      # in a custom SELECT (e.g. COUNT) would break the CTE, but those are already excluded by the
      # group_values.empty? guard.  The outer query retains the original select_values untouched,
      # so callers with a custom SELECT still get exactly the columns they asked for.
      #
      # except(:eager_load, :includes, :preload) strips association-loading directives from the
      # inner query: they have no purpose in an ID-only CTE scan and would cause AR to emit a
      # LEFT OUTER JOIN and dozens of aliased columns (t0_r0, t1_r0 …) inside the subquery.
      # The outer query keeps these values, so associations are still loaded for the result set.
      record_ids = ordered_relation
        .except(:eager_load, :includes, :preload)
        .reselect(primary_key => klass.model_name.to_s.foreign_key)

      ordered_relation
        .except(:limit, :offset)
        .with(CTE_NAME => record_ids)
        .joins(CTE_NAME)
        .load
        .records
    end

    def records_via_split_queries
      ids = ids_via_split_queries
      return [] if ids.empty?

      # The ID scan already applied every filter, so WHERE, ORDER and the joins are replaced by
      # the ID list and its order.  Association-loading directives are kept for the page records.
      ordered_ids = ids.map { |id| connection.quote(id) }.join(',')
      except(:joins, :left_outer_joins, :where, :order, :limit, :offset)
        .where(klass.primary_key => ids)
        .order(Arel.sql("FIELD(#{qualified_primary_key}, #{ordered_ids})"))
        .load
        .records
    end

    def ids_via_split_queries
      ordered_relation = order_values.empty? ? order(qualified_primary_key) : self

      # Association-loading directives are stripped for the same reason as in the CTE strategy.
      ordered_relation.except(:eager_load, :includes, :preload).pluck(qualified_primary_key)
    end

    # Joined tables may have a column with the same name, so the PK must be table-qualified.
    def qualified_primary_key
      Arel.sql("#{klass.quoted_table_name}.#{connection.quote_column_name(klass.primary_key)}")
    end
  end
end
