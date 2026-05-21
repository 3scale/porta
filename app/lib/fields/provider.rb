# frozen_string_literal: true

module Fields
  module Provider

    class ProviderFields
      def initialize(provider)
        @provider = provider
      end

      def for(klass)
        columns = klass.column_names
        defined = fields_definitions.by_target(klass.name.underscore).map(&:name)

        (columns + defined).uniq
      end

      protected

      def fields_definitions
        @provider.fields_definitions
      end
    end

    def defined_fields_names_for(klass)
      fields_definitions.by_target(klass.name.underscore).map(&:name)
    end

    def fields
      @provider_fields ||= ProviderFields.new(self)
    end
  end
end
