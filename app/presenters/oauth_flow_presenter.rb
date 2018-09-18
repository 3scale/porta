# frozen_string_literal: true

class OauthFlowPresenter
  DELEGATED_METHODS = AuthenticationProvider.attribute_names.map(&:to_sym) | %i[account errors callback_account]

  delegate(*DELEGATED_METHODS, to: :authentication_provider)

  # @param [AuthenticationProvider] authentication_provider
  # @param [ActionDispatch::Request] request
  def initialize(authentication_provider, request)
    @authentication_provider = authentication_provider
    @request = request

    build_client
    set_base_url
  end

  # Auth0 has different callback url(s) as it does not support wildcards
  # they have to be shown all together in order to save them in Auth0 client settings
  # TODO: Define Auth0CustomerOAuthFlowPresenter
  def sso_integration_callback_url
    # Usually http://example.com/auth/:system_name/callback
    url = callback_url(query: {})

    case kind
    when 'auth0'
      # e.g. http://example.com/auth/invitations/auth0/auth0_123abc/callback
      invitation_signup = client.callback_url("#{base_url}/invitations")

      [url, invitation_signup].join(', ')
    else
      url
    end
  end

  def callback_url(query: query_parameters)
    client.callback_url(base_url, query)
  end

  def authorize_url
    authentication_provider.authorize_url || client.authorize_url(base_url, query_parameters)
  end

  def self.name
    'AuthenticationProvider'
  end

  def self.wrap(authentication_providers, *args)
    authentication_providers.map { |authentication_provider| new(authentication_provider, *args) }
  end

  private

  attr_reader :authentication_provider, :request, :client, :base_url

  def build_client
    @client = ThreeScale::OAuth2::Client.build(authentication_provider).tap do |new_client|
      new_client.client.connection.ssl.verify = authentication_provider.ssl_verify_mode
    end
  rescue ::ThreeScale::OAuth2::KeycloakClient::MissingRealmError
    @client = NullClient.new
  end

  def set_base_url
    @base_url = ThreeScale::Domain.callback_endpoint(request, callback_account, account_domain)
  end

  def query_parameters
    request.query_parameters.merge(domain_parameters).except(:code)
  end

  def domain_parameters
    account_domain == callback_domain ? {} : { domain: callback_domain }
  end

  def callback_domain
    authentication_provider.account.domain
  end

  def account_domain
    callback_account.try(:domain)
  end

  class NullClient
    def callback_url; end
    def authorize_url; end
  end
end
