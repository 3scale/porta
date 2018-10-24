# frozen_string_literal: true

module ServiceDiscovery
  class TokenRetriever
    class UnknownAuthenticationMethodError < StandardError; end

    # @param user [User|NilClass] User to fetch the access token
    #   * When the authentication method is service_account, user is not relevant.
    #     It will use the bearer_token in the config
    #   * When the authentication method is oauth, user access token is required
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

    def service_usable?
      access_token.present?
    end

    def service_accessible?
      case
      when oauth?, service_account?
        ServiceDiscovery::OAuthConfiguration.instance.available?
      else
        raise UnknownAuthenticationMethodError, "Unknown authentication_method: '#{authentication_method}'"
      end
    end

    def access_token
      return unless service_accessible?
      oauth? ? @user.provided_access_tokens.valid.first&.value : config.bearer_token
    end
  end
end
