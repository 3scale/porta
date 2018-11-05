class ProviderOauthFlowPresenter < OauthFlowPresenter
  delegate :human_kind, to: :authentication_provider

  include Rails.application.routes.url_helpers

  # @param [AuthenticationProvider] authentication_provider
  # @param [ActionDispatch::Request] request
  def initialize(authentication_provider, request, self_domain)
    @self_domain = self_domain

    super(authentication_provider, request)
  end

  def test_flow_callback_url
    uri = URI.parse(base_url)
    uri.path = provider_admin_account_flow_testing_callback_path(system_name: authentication_provider.system_name)
    uri.to_s
  end

  private

  attr_reader :self_domain

  def domain_parameters
    callback_account.self_domain == self_domain ? {} : { self_domain: self_domain }
  end

  def account_domain
    self_domain
  end
end
