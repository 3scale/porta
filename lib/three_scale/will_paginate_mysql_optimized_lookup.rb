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
  # It applies to paginated MySQL relations with CTE support and a single-column
  # primary key. The relation must have no custom select, joins or eager loading,
  # grouping, HAVING, DISTINCT, custom FROM, existing CTE, or lock. Other relation
  # shapes use WillPaginate's usual query.
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
      current_page.present? &&
        limit_value.present? &&
        connection.supports_common_table_expressions? &&
        klass.primary_key.is_a?(String) &&
        select_values.empty? &&
        joins_values.empty? &&
        left_outer_joins_values.empty? &&
        eager_load_values.empty? &&
        !eager_loading? &&
        group_values.empty? &&
        having_clause.empty? &&
        !distinct_value &&
        from_clause.empty? &&
        with_values.empty? &&
        lock_value.nil?
    end

    def optimized_lookup_records
      primary_key = klass.primary_key
      ordered_relation = order_values.empty? ? order(primary_key) : self
      page_ids = ordered_relation.select(primary_key => klass.model_name.to_s.foreign_key)

      ordered_relation
        .except(:limit, :offset)
        .with(CTE_NAME => page_ids)
        .joins(CTE_NAME)
        .load
        .records
    end
  end
end
