# frozen_string_literal: true

module ServiceDiscovery
  class TokenRetriever

    def initialize(user=nil)
      @user = user
    end

    delegate :oauth?, :service_account?, to: :authentication_method

    def config
      ThreeScale.config.service_discovery
    end

    def authentication_method
      ActiveSupport::StringInquirer.new(config.authentication_method.presence || 'service_account')
    end

    def usable?
      access_token.present?
    end

    def accessible?
      case
      when oauth?, service_account?
        ServiceDiscovery::OAuthConfiguration.instance.available?
      else
        raise "Unknown authentication_method: '#{authentication_method}'"
      end
    end

    def access_token
      return unless accessible?
      oauth? ? @user.provided_access_tokens.valid.first&.value : config.bearer_token
    end
  end
end
