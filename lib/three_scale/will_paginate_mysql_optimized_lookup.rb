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
      return super unless optimized_lookup?

      load_records(optimized_lookup_records) unless loaded?
      super
    end

    private

    def optimized_lookup?
      current_page.present? &&
        limit_value.present? &&
        connection.supports_common_table_expressions? &&
        optimized_lookup_query_shape?
    end

    def optimized_lookup_query_shape?
      simple_model_rows? && unaggregated_rows? && default_query_context?
    end

    def simple_model_rows?
      klass.primary_key.is_a?(String) &&
        select_values.empty? &&
        unjoined_rows?
    end

    def unjoined_rows?
      joins_values.empty? &&
        left_outer_joins_values.empty? &&
        no_eager_loading?
    end

    def no_eager_loading?
      eager_load_values.empty? &&
        !eager_loading?
    end

    def unaggregated_rows?
      group_values.empty? &&
        having_clause.empty? &&
        !distinct_value
    end

    # :reek:NilCheck
    def default_query_context?
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
