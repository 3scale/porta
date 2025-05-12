# frozen_string_literal: true

class Admin::Api::Account::ProxyConfigsController < Admin::Api::BaseController
  include ApiAuthentication::ByToken

  represents :json, entity: ::ProxyConfigRepresenter
  represents :json, collection: ::ProxyConfigsRepresenter

  clear_respond_to
  respond_to :json

  rescue_from(ProxyConfig::InvalidEnvironmentError) do
    render_error 'invalid environment', status: :unprocessable_entity
  end

  # Proxy Configs List (Provider)
  # GET /admin/api/account/proxy_configs/{environment}.json
  def index
    respond_with proxy_configs.order(:id).paginate(pagination_params)
  end

  private

  def proxy_configs
    @proxy_configs ||= ProxyConfig.joins(:proxy)
      .where(proxies: { service_id: accessible_services.pluck(:id) })
      .by_environment(environment)
      .by_host(host)
      .by_version(version)
  end

  def accessible_services
    (current_user || current_account).accessible_services
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
