# frozen_string_literal: true

class Master::Api::Proxy::ConfigsController < Master::Api::BaseController
  include Roar::Rails::ControllerAdditions

  include ApiAuthentication::ByAccessToken
  self.access_token_scopes = :account_management

  represents :json, collection: ::ProxyConfigsRepresenter

  rescue_from(ProxyConfig::InvalidEnvironmentError) do
    render_error 'invalid environment', status: :bad_request
  end

  def index
    respond_with(service_proxy_configs)
  end

  protected

  def service_proxy_configs
    ProxyConfig.current_versions.by_environment(environment).by_host(host)
  end

  def environment
    params.require(:environment)
  end

  def host
    params[:host].presence
  end

  def authenticate!
    return if logged_in?
    render plain: 'unauthorized', status: 401
  end
end
