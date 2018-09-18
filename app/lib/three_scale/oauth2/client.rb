# frozen_string_literal: true
module ThreeScale
  module OAuth2
    module Client
      module_function

      Config = Struct.new(:identifier_key, :user_info_url)

      Options = Struct.new(:site, :token_url, :authorize_url, :connection_opts) do
        def to_hash
          { site: site, token_url: token_url, authorize_url: authorize_url, connection_opts: connection_opts }.reject { |_, v| !v }
        end
      end

      Authentication = Struct.new(:system_name, :credentials, :options, :config, :account) do
        delegate :client_id, :client_secret, to: :credentials
        delegate :identifier_key, :user_info_url, to: :config
      end

      def client_class(kind)
        case kind
        when 'github'
          ThreeScale::OAuth2::GithubClient
        when 'auth0'
          ThreeScale::OAuth2::Auth0Client
        when 'keycloak'
          ThreeScale::OAuth2::KeycloakClient
        when 'redhat_customer_portal'
          redhat_customer_portal_client_class
        else
          ThreeScale::OAuth2::ClientBase
        end
      end

      def redhat_customer_portal_client_class
        case ThreeScale.config.redhat_customer_portal.flow
        when 'auth_code'
          ThreeScale::OAuth2::RedhatCustomerPortalClient
        when 'implicit'
          ThreeScale::OAuth2::RedhatCustomerPortalClient::ImplicitFlow
        else
          raise(ThreeScale::OAuth2::ClientBase::UnsupportedFlowError, system_name: 'redhat_customer_portal')
        end
      end

      # @param [::AuthenticationProvider] authentication_provider
      # @return [::ThreeScale::OAuth::ClientBase]
      # @return [::ThreeScale::OAuth::GithubClient]
      # @return [::ThreeScale::OAuth::Auth0Client]
      # @return [::ThreeScale::OAuth::KeycloakClient]
      # @return [::ThreeScale::OAuth::KeycloakClient::ImplicitFlow]
      def build(authentication_provider)
        authentication = build_authentication(authentication_provider)
        client_class(authentication_provider.kind).new(authentication)
      end

      # @param [::AuthenticationProvider] authentication_provider
      # @return [::ThreeScale::OAuth::Client::Authentication]
      def build_authentication(authentication_provider)
        system_name = authentication_provider.system_name
        credentials = authentication_provider.credentials
        options = build_authentication_options(authentication_provider)
        config = build_authentication_config(authentication_provider)
        account = authentication_provider.account

        Authentication.new(system_name, credentials, options, config, account)
      end

      # @param [::AuthenticationProvider] authentication_provider
      # @return [::ThreeScale::OAuth::Client::Options]
      def build_authentication_options(authentication_provider)
        Options.new(
          authentication_provider.site.presence,
          authentication_provider.token_url.presence,
          authentication_provider.authorize_url.presence,
          { ssl: { verify_mode: authentication_provider.ssl_verify_mode } })
      end

      # @param [::AuthenticationProvider] authentication_provider
      # @return [::ThreeScale::OAuth::Client::Config]
      def build_authentication_config(authentication_provider)
        Config.new(authentication_provider.identifier_key,
                   authentication_provider.user_info_url)
      end
    end
  end
end
