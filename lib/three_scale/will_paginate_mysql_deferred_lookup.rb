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
