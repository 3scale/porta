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
  ##~ op.parameters.add :name => "host",    :description => "Filter by host",    :dataType => "string", :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "version", :description => "Filter by version", :dataType => "string", :required => false, :paramType => "query"
  ##~ op.parameters.add @parameter_page
  ##~ op.parameters.add @parameter_per_page
  #
  def index
    respond_with proxy_configs.order(id: :asc).paginate(pagination_params)
  end

  private

  def proxy_configs
    @proxy_configs ||= if version == 'latest'
                         ProxyConfig.latest_versions(environment: environment, proxy_ids: proxy_ids)
                       else
                         ProxyConfig.by_version(version).by_environment(environment).by_proxy_ids(proxy_ids)
    end.by_host(host)
  end

  def proxy_ids
    ProxiesForProviderOwnerAndWatcherQuery.call(owner: current_account, watcher: current_user || current_account).select(:id)
  end

  def environment
    params.require(:environment)
  end

  def host
    params.permit(:host)[:host]
  end

  def version
    params.permit(:version)[:version]
  end
end
