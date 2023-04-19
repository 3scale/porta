# frozen_string_literal: true

module BackendApiLogic
  module MetricExtension
    extend ActiveSupport::Concern

    SYSTEM_NAME_SUFFIX_SEPARATOR = '.'

    included do
      before_validation :reset_extended_system_name, if: :backend_api_metric?
      validate :unique_extended_system_name, if: :backend_api_metric?
      before_save :extend_system_name, if: :backend_api_metric?
    end

    def backend_api_metric?
      owner_type == 'BackendApi'
    end

    def service_metric?
      service_id || owner_type == 'Service'
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

      def build_extended_system_name(system_name, owner_id:)
        parts = [system_name_without_suffix(system_name, owner_id: owner_id), owner_id]
        parts.compact.join SYSTEM_NAME_SUFFIX_SEPARATOR
      end

      def system_name_without_suffix(system_name, owner_id:)
        system_name.to_s.gsub(/#{Regexp.escape(SYSTEM_NAME_SUFFIX_SEPARATOR)}#{owner_id}\z/, '')
      end
    end

    protected

    def system_name_without_suffix
      self.class.system_name_without_suffix(attributes['system_name'], owner_id: owner_id)
    end

    def extended_system_name
      return system_name_without_suffix unless backend_api_metric?
      self.class.build_extended_system_name(attributes['system_name'], owner_id: owner_id)
    end

    def extend_system_name
      self.system_name = extended_system_name
    end

    def reset_extended_system_name
      return if system_name.blank?
      self.system_name = system_name_without_suffix
    end

    def unique_extended_system_name
      metric_id = id
      metric_extended_system_name = self.extended_system_name
      return true unless owner.metrics.where.has{ (system_name == metric_extended_system_name) & (id != metric_id) }.exists?
      errors.add :system_name, :taken
    end
  end
end
