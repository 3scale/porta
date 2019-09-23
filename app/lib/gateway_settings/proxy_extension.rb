# frozen_string_literal: true

module GatewaySettings
  module ProxyExtension
    extend ActiveSupport::Concern
    included do
      has_one :gateway_configuration, dependent: :delete, inverse_of: :proxy, autosave: true
      # TODO: In the future, stop using columns and put all configuration to this class
      delegate(*GatewayConfiguration.accessors, to: :gateway_configuration)
    end

    def gateway_configuration
      super || build_gateway_configuration
    end
  end
end
