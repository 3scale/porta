# frozen_string_literal: true

module ThreeScale
  # Normal pagination uses LIMIT/OFFSET to skip rows before returning full records:
  #   SELECT widgets.* FROM widgets ORDER BY widgets.id LIMIT 50 OFFSET 10000
  #
  # The optimized lookup splits this in two:
  # - The ID query keeps the filters, JOINs and ORDER BY of the relation, but selects nothing except
  #   IDs.  This lets MySQL do the large OFFSET on narrow index data instead of wide rows.
  # - The data query then loads the actual records, and their associations, for those IDs.
  #
  # There is no gain on page 1 (OFFSET 0), so the optimization is skipped there.  Note that the caller
  # is still responsible for proper indices on the filter and order columns — without them the ID
  # query will be slow regardless of this optimization.
  #
  # It applies to paginated relations of a model with a single-column primary key, without grouping,
  # HAVING, DISTINCT, custom FROM, lock or eager loading (see below).  Relations without joins also
  # need no existing CTE.  Any other relation shape uses WillPaginate's usual query, and a warning
  # with the reason, the model and the controller action is logged.  No warning is logged for page 1
  # or for a relation that is not paginated.  Two strategies exist:
  #
  # 1. Without joins, on MySQL 8.0+ (CTE support), a single query using the ID query as a CTE:
  #      WITH will_paginate_page_ids AS (
  #        SELECT widgets.id AS widget_id FROM widgets
  #        ORDER BY widgets.id LIMIT 50 OFFSET 10000
  #      )
  #      SELECT widgets.* FROM widgets
  #      JOIN will_paginate_page_ids ON will_paginate_page_ids.widget_id = widgets.id
  #
  # 2. Split queries, used for relations with joins (and no custom SELECT, which could use the
  #    joined tables) and as the fallback when CTEs are not supported.  Two separate queries,
  #    the data query is by primary key alone:
  #      SELECT widgets.id FROM widgets INNER JOIN ... ORDER BY ... LIMIT 50 OFFSET 10000
  #        => 17, 4, 9, ...  (the IDs of the page, in the order requested by the ORDER BY)
  #      SELECT widgets.* FROM widgets WHERE widgets.id IN (17, 4, 9, ...)
  #        ORDER BY FIELD(widgets.id, 17, 4, 9, ...)
  #    `IN` only selects which rows to load and says nothing about their order.  The original
  #    ORDER BY can't be repeated in the data query, as it may use columns of the joined tables, so
  #    `FIELD(...)` sorts the rows by their position in the ID list instead, restoring the order of
  #    the ID query.  Join cardinality is the caller's responsibility: the page is whatever the ID
  #    query returned.
  #
  # `includes` and `preload` are applied to the data query only, never to the ID query.  A relation
  # whose associations AR loads with a JOIN (`eager_load`, or `includes` with `references`) is not
  # optimized, because the ID query would lack that JOIN.  To get the optimization with a condition
  # or order on an association table, use an explicit `joins` plus `preload`.
  #
  # You can also see https://bugs.mysql.com/bug.php?id=109173
  module WillPaginateMysqlOptimizedLookup
    CTE_NAME = :will_paginate_page_ids

    # Relation shapes that can't use the optimized lookup on any code path, as `reason => check`.  The first
    # check that holds gives the reason logged.  The checks run in the relation, see `reason_not_optimizable`.
    UNSUPPORTED_SHAPES = {
      # A nil PK (no primary key) or an Array PK (composite key) cannot be used as a single lookup column.
      'no single-column primary key' => -> { !klass.primary_key.is_a?(String) },
      # GROUP BY changes the unit of pagination from rows to groups; the PK no longer identifies a single row.
      'GROUP BY' => -> { group_values.any? },
      # HAVING without GROUP BY is meaningless, and with it the pagination semantics are already broken (see above).
      'HAVING' => -> { !having_clause.empty? },
      # DISTINCT deduplicates before LIMIT/OFFSET, making the ID list potentially wrong after the lookup.
      'DISTINCT' => -> { distinct_value },
      # A custom FROM (alias, subquery, index hint) breaks the table reference the lookup relies on.
      'custom FROM' => -> { !from_clause.empty? },
      # Locking requires atomicity across the whole fetch; splitting it into phases breaks that.
      'lock' => -> { lock_value },
      # `eager_loading?` is a public AR method, true when AR loads associations with a JOIN: with
      # `eager_load`, with `includes` and `references` (or a hash condition on the included table), or
      # with `includes` of an association that is also in `joins`.  The ID query has no association
      # loading, so it lacks that JOIN and any condition or order on the table would fail there.  Such
      # relations use the usual query.  `includes` and `preload` alone are loaded with separate queries
      # and are fine.
      #
      # Known limits, kept on purpose to stay simple and rely on public API only:
      # - `includes(:x).joins(:x)` is not optimized although `includes` can be stripped without beaking
      #   conditions or order. But it is harder to detect. One can use `joins(:x).preload(:x)`.
      # - A string condition on an included table (`where("xs.col = 1")`) has no `references`, so it is
      #   not detected. AR would not join the table either, so it will break without the optimizer.
      # - API responders strip `includes` and `preload` before loading (to run `#stale?` first), so
      #   `includes` + `references` will not be detected on that code path, but `eager_load` is.
      'eager loading (eager_load, or includes with references)' => -> { eager_loading? }
    }.freeze

    # Additional limits of the split queries, used for relations with joins.
    UNSUPPORTED_WITH_JOINS = {
      # The data query has no joins, so a custom SELECT that may use joined columns can't be
      # replayed there.  This could easily be relaxed to accept a SELECT made only of symbols,
      # as AR qualifies those with the main table.
      'custom SELECT with joins or references' => -> { select_values.any? }
    }.freeze

    # Additional limits of the CTE, used for relations without joins.
    UNSUPPORTED_WITHOUT_JOINS = {
      # Adding our CTE to a relation that already has one risks name collisions and nested CTE scope errors.
      'existing CTE (WITH)' => -> { with_values.any? }
    }.freeze

    def to_a
      unless loaded?
        records = records_via_optimal_strategy
        load_records(records) if records
      end
      super
    end

    private

    # Returns nil when the relation is not eligible, so WillPaginate's usual query is used.
    def records_via_optimal_strategy
      return unless optimization_worthwhile? && can_optimize?

      cte_usable? ? records_via_cte : records_via_split_queries
    end

    # The CTE needs MySQL 8.0+ and no joins, otherwise the split queries are used.
    def cte_usable?
      !query_with_joins? && connection.supports_common_table_expressions?
    end

    # The CTE can't be used with joins: they need the ID query to be a separate query that carries them.
    def query_with_joins?
      joins_values.any? || left_outer_joins_values.any?
    end

    # Relations that are not paginated or gain nothing from the optimization, they are not worth a warning.
    def optimization_worthwhile?
      # Only paginated relations (WillPaginate sets current_page via .paginate).
      current_page.present? &&
        # The gain comes from not reading full rows for the skipped OFFSET; page 1 (OFFSET 0) is already fast.
        offset_value.positive? &&
        # Skip when the caller already selected only the PK — a plain
        # LIMIT/OFFSET on a narrow index-only scan is already optimal.
        !(select_values.size == 1 && select_values.first.to_s == klass.primary_key)
    end

    # Returns why the relation can't use the optimized lookup, or nil when it can.
    def reason_not_optimizable
      reason_not_supported(UNSUPPORTED_SHAPES) ||
        reason_not_supported(query_with_joins? ? UNSUPPORTED_WITH_JOINS : UNSUPPORTED_WITHOUT_JOINS)
    end

    # Returns why the relation can't use the optimized lookup according to the given checks, or nil.
    def reason_not_supported(checks)
      checks.find { |_reason, check| instance_exec(&check) }&.first
    end

    # Whether the relation shape supports the optimized lookup.  When it doesn't, logs the reason, the
    # model and the controller action, as a hint that the caller may want to change the relation.
    def can_optimize?
      reason = reason_not_optimizable
      return true unless reason

      controller = ActiveSupport::ExecutionContext.to_h[:controller]
      origin = controller ? "#{controller.class.name}##{controller.action_name}" : 'no controller'
      Rails.logger.warn "[WillPaginateMysqlOptimizedLookup] #{klass.name} page #{current_page} " \
                        "is not optimized (#{reason}), called from #{origin}"
      false
    end

    def records_via_cte
      primary_key = klass.primary_key
      record_ids = ids_relation.reselect(primary_key => klass.model_name.to_s.foreign_key)

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

      # The ID query already applied every filter, so WHERE, ORDER and the joins are replaced by
      # the ID list and its order.  Association loading is kept for the data query.
      ordered_ids = ids.map { |id| connection.quote(id) }.join(',')
      except(:joins, :left_outer_joins, :where, :order, :limit, :offset)
        .where(klass.primary_key => ids)
        .order(Arel.sql("FIELD(#{qualified_primary_key}, #{ordered_ids})"))
        .load
        .records
    end

    def ids_via_split_queries
      connection.select_values(ids_relation.reselect(qualified_primary_key).arel)
    end

    # The ID query shared by both strategies: the filters and the order of the page, nothing else.
    #
    # Association loading is stripped because it will load unnecessary data.  The data query keeps it,
    # so associations are still loaded for the result set.
    #
    # Callers reselect only the PK, so the ID query stays narrow whatever the data query selects.
    def ids_relation
      ordered_relation.except(:eager_load, :includes, :preload)
    end

    def ordered_relation
      order_values.empty? ? order(qualified_primary_key) : self
    end

    # Joined tables may have a column with the same name, so the PK must be table-qualified.
    def qualified_primary_key
      Arel.sql("#{klass.quoted_table_name}.#{connection.quote_column_name(klass.primary_key)}")
    end
  end
end
