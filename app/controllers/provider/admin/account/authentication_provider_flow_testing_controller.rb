# frozen_string_literal: true

class Provider::Admin::Account::AuthenticationProviderFlowTestingController < Provider::Admin::Account::BaseController

  def auth_show
    auth_url = URI.parse(auth_presenter.authorize_url)
    query = Rack::Utils.parse_nested_query(auth_url.query)
    query['redirect_uri'] = auth_presenter.test_flow_callback_url
    auth_url.query = query.to_query
    redirect_to auth_url.to_s
  end

  def callback
    strategy = Authentication::Strategy.build_provider(site_account_request.find_provider)
    auth_params = params.permit(:token, :expires_at, :system_name, :code).merge(request: request)
    if strategy.authenticate(auth_params)
      flash[:success] = 'Authentication flow successfully tested.'
    else
      flash[:error] = strategy.error_message || 'Authentication flow could not be tested.'
    end
    redirect_to provider_admin_account_authentication_provider_path(strategy.authentication_provider)
  end

  private

  def auth_presenter
    ProviderOauthFlowPresenter.new(authentication_provider, request, request.host)
  end

  def authentication_providers
    current_account.self_authentication_providers
  end

  def authentication_provider
    authentication_providers.find(params[:id])
  end
end
