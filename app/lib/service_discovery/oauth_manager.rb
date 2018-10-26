# frozen_string_literal: true

module ServiceDiscovery
  class OAuthManager
    class UnknownAuthenticationMethodError < StandardError; end

    include ::ServiceDiscovery::Config

    delegate :service_accessible?, to: 'ServiceDiscovery::OAuthConfiguration.instance'

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

    def access_token
      return unless service_accessible?
      oauth? ? @user.provided_access_tokens.valid.first&.value : bearer_token
    end
  end
end
