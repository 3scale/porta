# frozen_string_literal: true

module ThreeScale
  # Normal pagination uses LIMIT/OFFSET to skip rows before returning full records:
  #   SELECT widgets.* FROM widgets ORDER BY widgets.id LIMIT 50 OFFSET 10000
  #
  # The optimized lookup selects IDs for the page first, then fetches those rows:
  #   WITH will_paginate_page_ids AS (
  #     SELECT widgets.id AS widget_id FROM widgets
  #     ORDER BY widgets.id LIMIT 50 OFFSET 10000
  #   )
  #   SELECT widgets.* FROM widgets
  #   JOIN will_paginate_page_ids ON will_paginate_page_ids.widget_id = widgets.id
  #
  # The performance gain comes from the large OFFSET being paid only in an index-only
  # scan (narrow PK column) rather than in full wide-row reads.  There is no gain on
  # page 1 (OFFSET 0), so the optimization is skipped there.  Note that the caller is
  # still responsible for proper indices on the filter and order columns — without them
  # the CTE scan will be slow regardless of this optimization.
  #
  # It applies to paginated MySQL relations with CTE support and a single-column
  # primary key. The relation must have no joins, references, grouping, HAVING,
  # DISTINCT, custom FROM, existing CTE, or lock. Other relation shapes use
  # WillPaginate's usual query.
  module WillPaginateMysqlOptimizedLookup
    CTE_NAME = :will_paginate_page_ids

    def to_a
      return super unless can_optimize?

      load_records(optimized_lookup_records) unless loaded?
      super
    end

    private

    # :reek:NilCheck
    def can_optimize? # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      # Only paginated relations (WillPaginate sets current_page via .paginate).
      current_page.present? &&
        # The gain comes from avoiding a full-row scan at high offsets; page 1 (OFFSET 0) is already fast.
        offset_value.positive? &&
        # CTEs require MySQL 8.0+; fall back to the standard query on older versions.
        connection.supports_common_table_expressions? &&
        # A nil PK (no primary key) or an Array PK (composite key) cannot be aliased as a single CTE column.
        klass.primary_key.is_a?(String) &&
        # Paginating over a JOIN is an unusual pattern in Rails (AR collapses join rows into one object
        # per PK anyway), so it is not a use case we want to spend engineering effort on right now.
        # Whether the CTE rewrite would even be correct or faster depends heavily on join cardinality
        # and filter selectivity, which we cannot reason about at query-build time.
        joins_values.empty? &&
        # LEFT JOINs carry the same concerns as inner joins.
        left_outer_joins_values.empty? &&
        # references forces AR into a JOIN-based load strategy, carrying the same concerns as above.
        references_values.empty? &&
        # GROUP BY changes the unit of pagination from rows to groups; the PK no longer identifies a single row.
        group_values.empty? &&
        # HAVING without GROUP BY is meaningless, and with it the pagination semantics are already broken (see above).
        having_clause.empty? &&
        # DISTINCT deduplicates before LIMIT/OFFSET, making the CTE ID list potentially wrong after the JOIN.
        !distinct_value &&
        # A custom FROM (alias, subquery, index hint) breaks the table reference the CTE JOIN relies on.
        from_clause.empty? &&
        # Adding our CTE to a relation that already has one risks name collisions and nested CTE scope errors.
        with_values.empty? &&
        # Locking requires atomicity across the whole fetch; splitting into a CTE phase + JOIN phase breaks that.
        lock_value.nil?
    end

    def optimized_lookup_records
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
      page_ids = ordered_relation
        .except(:eager_load, :includes, :preload)
        .reselect(primary_key => klass.model_name.to_s.foreign_key)

      ordered_relation
        .except(:limit, :offset)
        .with(CTE_NAME => page_ids)
        .joins(CTE_NAME)
        .load
        .records
    end
  end
end
