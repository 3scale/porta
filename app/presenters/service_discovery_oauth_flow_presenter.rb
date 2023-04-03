# frozen_string_literal: true

# TODO: Refactor! This class is really similar to RedhatCustomerOAuthFlowPresenter
class ServiceDiscoveryOAuthFlowPresenter < OAuthFlowPresenter

  def initialize(account, request)
    super(account.service_discovery_authentication_provider, request)

    build_redirect_uri
  end

  def callback_url(query: query_parameters)
    request.query = '' unless query
    redirect_uri.call
  end

  def authorize_url
    client.authorize_url(
      redirect_uri.base_url,
      redirect_uri.query_options.merge(referrer: request.fullpath)
    )
  end

  private

  attr_reader :redirect_uri

  def domain_parameters
    { self_domain: request.host }
  end

  def build_redirect_uri
    @redirect_uri = ThreeScale::OAuth2::ServiceDiscoveryClient::RedirectUri.new(client, request)
  end
end
