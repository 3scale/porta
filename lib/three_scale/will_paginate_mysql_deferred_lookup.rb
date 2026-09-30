# frozen_string_literal: true

module ThreeScale
  module WillPaginateMysqlDeferredLookup
    CTE_NAME = :will_paginate_page_ids

    def to_a
      return super unless deferred_lookup?

      load_records(deferred_lookup_records) unless loaded?
      super
    end

    private

    def deferred_lookup?
      current_page.present? &&
        limit_value.present? &&
        connection.supports_common_table_expressions? &&
        deferred_lookup_query_shape?
    end

    def deferred_lookup_query_shape?
      # Deferred lookup selects IDs for the requested page, then fetches the full
      # records for those IDs. It requires a single-column primary key and a plain
      # model query. Custom selects, joins, or eager loading can change which records
      # the IDs refer to. Grouping, HAVING, or DISTINCT can change the returned rows.
      # Custom FROM clauses can change the source, and existing CTEs can conflict
      # with the added CTE. Locks must keep their original behavior, so those queries
      # use WillPaginate's normal path.
      simple_model_rows? && unaggregated_rows? && default_query_context?
    end

    def simple_model_rows?
      klass.primary_key.is_a?(String) &&
        select_values.empty? &&
        joins_values.empty? &&
        left_outer_joins_values.empty? &&
        eager_load_values.empty? &&
        !eager_loading?
    end

    def unaggregated_rows?
      group_values.empty? &&
        having_clause.empty? &&
        !distinct_value
    end

    def default_query_context?
      from_clause.empty? &&
        with_values.empty? &&
        lock_value.nil?
    end

    def deferred_lookup_records
      ordered_relation = order_values.empty? ? order(klass.primary_key) : self
      page_ids = ordered_relation.select(klass.primary_key => deferred_lookup_foreign_key)

      ordered_relation
        .except(:limit, :offset)
        .with(CTE_NAME => page_ids)
        .joins(CTE_NAME)
        .load
        .records
    end

    def deferred_lookup_foreign_key
      klass.model_name.singular.foreign_key
    end
  end
end
