# frozen_string_literal: true

class Admin::Api::Services::Proxy::ConfigsController < Admin::Api::Services::BaseController

  include ApiAuthentication::BySsoToken

  represents :json, entity: ::ProxyConfigRepresenter
  represents :json, collection: ::ProxyConfigsRepresenter

  clear_respond_to
  respond_to :json

  rescue_from(ProxyConfig::InvalidEnvironmentError) do
    render_error 'invalid environment', status: :bad_request
  end

  # Proxy Configs List (Service)
  # GET /admin/api/services/{service_id}/proxy/configs/{environment}.json
  def index
    respond_with(service_proxy_configs)
  end

  def index_by_host
    respond_with(host_proxy_configs)
  end

  # Proxy Config Show Latest
  # GET /admin/api/services/{service_id}/proxy/configs/{environment}/latest.json
  def latest
    proxy_config = service_proxy_configs.newest_first.first!

    respond_with(proxy_config)
  end

  # Proxy Config Show
  # GET /admin/api/services/{service_id}/proxy/configs/{environment}/{version}.json
  def show
    respond_with(proxy_config)
  end

  # Proxy Config Promote
  # POST /admin/api/services/{service_id}/proxy/configs/{environment}/{version}/promote.json
  def promote
    destination_environment = params.require(:to)
    promoted_proxy_config   = proxy_config.clone_to(environment: destination_environment)

    respond_with(promoted_proxy_config)
  end

  private

  def proxy_config
    @proxy_config ||= service_proxy_configs.find_by!(version: params[:version])
  end

  def service_proxy_configs
    service.proxy.proxy_configs.by_environment(environment)
  end

  def host_proxy_configs
    current_account.accessible_proxy_configs
      .by_environment(environment).by_host(host).current_versions
  end

  def host
    params.require(:host)
  end

  def environment
    params.require(:environment)
  end
end
