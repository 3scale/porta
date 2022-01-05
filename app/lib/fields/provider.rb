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
        protected =  klass.protected_attributes.to_a

        ((columns + defined) - protected).uniq
      end

      protected

      def fields_definitions
        @provider.fields_definitions
      end
    end

    def fields
      @provider_fields ||= ProviderFields.new(self)
    end
  end
end
