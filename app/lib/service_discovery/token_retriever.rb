# frozen_string_literal: true

module ServiceDiscovery
  class TokenRetriever
    class UnknownAuthenticationMethodError < StandardError; end

    delegate :available?, :oauth?, :bearer_token, :service_account?, :authentication_method, to: 'ServiceDiscovery::OAuthConfiguration.instance'
    private :available?, :oauth?, :bearer_token, :service_account?, :authentication_method

    # @param user [User|NilClass] User to fetch the access token
    #   * When the authentication method is service_account, user is not relevant.
    #     It will use the bearer_token in the config
    #   * When the authentication method is oauth, user access token is required
    def initialize(user=nil)
      @user = user
    end

    def service_usable?
      access_token.present?
    end

    def service_accessible?
      case
      when oauth?, service_account?
        available?
      else
        # raise UnknownAuthenticationMethodError, "Unknown authentication_method: '#{authentication_method}'"
        false
      end
    end

    def access_token
      return unless service_accessible?
      oauth? ? @user.provided_access_tokens.valid.first&.value : bearer_token
    end
  end
end
