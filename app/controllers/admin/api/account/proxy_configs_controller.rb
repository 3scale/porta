# frozen_string_literal: true

class Admin::Api::Account::ProxyConfigsController < Admin::Api::BaseController
  include ApiAuthentication::BySsoToken

  represents :json, entity: ::ProxyConfigRepresenter
  represents :json, collection: ::ProxyConfigsRepresenter

  clear_respond_to
  respond_to :json

  rescue_from(ProxyConfig::InvalidEnvironmentError) do
    render_error 'invalid environment', status: :unprocessable_entity
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/account/proxy_configs/{environment}.json"
  ##~ e.responseClass = "proxy_config"
  #
  ##~ op             = e.operations.add
  ##~ op.httpMethod  = "GET"
  ##~ op.summary     = "Proxy Configs List (Provider)"
  ##~ op.description = "Returns the Proxy Configs of the provider"
  ##~ op.group       = "proxy_config"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_environment
  ##~ op.parameters.add :name => "host", :description => "Find by host", :dataType => "string", :required => false, :paramType => "query"
  #
  def index
    respond_with proxy_configs.order(:id).paginate(pagination_params)
  end

  private

  def proxy_configs
    @proxy_configs ||= ProxyConfig.joins(:proxy)
      .where(proxies: { service_id: (System::Database.oracle? ? accessible_services.pluck(:id) : accessible_services.select(:id)) })
      .by_environment(environment)
      .by_host(host)
  end

  def accessible_services
    (current_user || current_account).accessible_services.order(:id)
  end

  def environment
    params.require(:environment)
  end

  def host
    params.permit(:host)[:host]
  end
end
