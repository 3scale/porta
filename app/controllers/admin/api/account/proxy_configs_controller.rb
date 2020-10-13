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

  def index
    respond_with proxy_configs.order(:id).paginate(pagination_params)
  end

  private

  def proxy_configs
    ProxyConfig.joins(:proxy).where("proxies.service_id in (?)", accessible_services.pluck(:id)).by_environment(environment)
  end

  def accessible_services
    (current_user || current_account).accessible_services.order(:id)
  end

  def environment
    params.require(:environment)
  end
end
