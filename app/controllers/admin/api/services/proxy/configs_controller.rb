# frozen_string_literal: true

class Admin::Api::Services::Proxy::ConfigsController < Admin::Api::Services::BaseController
  ##~ sapi = source2swagger.namespace("Account Management API")

  include ApiAuthentication::BySsoToken

  represents :json, entity: ::ProxyConfigRepresenter
  represents :json, collection: ::ProxyConfigsRepresenter

  clear_respond_to
  respond_to :json

  rescue_from(ProxyConfig::InvalidEnvironmentError) do
    render_error 'invalid environment', status: :bad_request
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/proxy/configs/{environment}.json"
  ##~ e.responseClass = "proxy_config"
  #
  ##~ op             = e.operations.add
  ##~ op.httpMethod  = "GET"
  ##~ op.summary     = "Proxy Configs List"
  ##~ op.description = "Returns the Proxy Configs of a Service"
  ##~ op.group       = "proxy_config"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add @parameter_environment
  #
  def index
    respond_with(service_proxy_configs)
  end

  def index_by_host
    respond_with(host_proxy_configs)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/proxy/configs/{environment}/latest.json"
  ##~ e.responseClass = "proxy_config"
  #
  ##~ op             = e.operations.add
  ##~ op.httpMethod  = "GET"
  ##~ op.summary     = "Proxy Config Show Latest"
  ##~ op.description = "Returns the latest Proxy Config."
  ##~ op.group       = "proxy_config"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add @parameter_environment
  #
  def latest
    proxy_config = service_proxy_configs.newest_first.first!

    respond_with(proxy_config)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/proxy/configs/{environment}/{version}.json"
  ##~ e.responseClass = "proxy_config"
  #
  ##~ op             = e.operations.add
  ##~ op.httpMethod  = "GET"
  ##~ op.summary     = "Proxy Config Show"
  ##~ op.description = "Returns a Proxy Config."
  ##~ op.group       = "proxy_config"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add @parameter_environment
  ##~ op.parameters.add @parameter_proxy_config_version_by_version
  #
  def show
    respond_with(proxy_config)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/proxy/configs/{environment}/{version}/promote.json"
  ##~ e.responseClass = "proxy_config"
  #
  ##~ op             = e.operations.add
  ##~ op.httpMethod  = "POST"
  ##~ op.summary     = "Proxy Config Promote"
  ##~ op.description = "Promotes a Proxy Config from one environment to another environment."
  ##~ op.group       = "proxy_config"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add @parameter_environment
  ##~ op.parameters.add @parameter_proxy_config_version_by_version
  ##~ op.parameters.add :name => "to", :description => "the name of the destination environment", :dataType => "string", :paramType => "query", :required => true
  #
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
