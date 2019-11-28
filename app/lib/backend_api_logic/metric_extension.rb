# frozen_string_literal: true

module BackendApiLogic
  module MetricExtension
    extend ActiveSupport::Concern

    SYSTEM_NAME_SUFFIX_SEPARATOR = '.'

    included do
      validate :unique_extended_system_name, if: :backend_api_metric?
      before_save :extend_system_name, if: :backend_api_metric?

      alias_method :system_name, :system_name_without_suffix
      public :system_name
    end

    def backend_api_metric?
      owner_type == 'BackendApi'
    end

    def parent_id_for_service(service)
      if backend_api_metric? && hits?
        service.metrics.hits&.id
      else
        parent_id
      end
    end

    module ClassMethods
      def hits_extended_system_name_as_sql
        Arel::Nodes::SqlLiteral.new("'hits#{SYSTEM_NAME_SUFFIX_SEPARATOR}' || #{quoted_table_name}.owner_id")
      end

      def hits_extended_system_name_regex
        /\Ahits(#{Regexp.escape(SYSTEM_NAME_SUFFIX_SEPARATOR)}\d+)?\z/
      end
    end

    def extended_system_name
      parts = [system_name_without_suffix]
      parts << owner_id if backend_api_metric?
      parts.compact.join SYSTEM_NAME_SUFFIX_SEPARATOR
    end

    protected

    def system_name_without_suffix
      attributes['system_name'].to_s.gsub(/#{Regexp.escape(SYSTEM_NAME_SUFFIX_SEPARATOR)}\d+\z/, '')
    end

    def extend_system_name
      self.system_name = extended_system_name
    end

    def unique_extended_system_name
      metric_id = id
      metric_extended_system_name = self.extended_system_name
      return true unless owner.metrics.where.has{ (system_name == metric_extended_system_name) & (id != metric_id) }.exists?
      errors.add :system_name, :taken
    end
  end
end
