# frozen_string_literal: true

class Admin::Api::Services::BackendApiConfigsController < Admin::Api::Services::BaseController
  self.access_token_scopes = :account_management

  before_action :authorize

  clear_respond_to
  respond_to :json

  wrap_parameters BackendApiConfig
  representer BackendApiConfig

  paginate only: :index

  def index
    backend_api_configs = service.backend_api_configs.accessible.order(:id).paginate(pagination_params)
    respond_with(backend_api_configs)
  end

  def create
    backend_api_config = service.backend_api_configs.create(create_params)
    respond_with(backend_api_config)
  end

  def destroy
    backend_api_config.destroy
    respond_with(backend_api_config)
  end

  def update
    backend_api_config.update(update_params)
    respond_with(backend_api_config)
  end

  private

  def backend_api_config
    @backend_api_config ||= service.backend_api_configs.accessible.find_by(backend_api_id: params[:id]) or raise ActiveRecord::RecordNotFound
  end

  def create_params
    params.require(:backend_api_config).permit(:path, :backend_api_id).tap do |backend_api_config_params|
      next unless (backend_api_id = backend_api_config_params.delete(:backend_api_id))
      backend_api_config_params[:backend_api] = current_account.backend_apis.accessible.find(backend_api_id)
    end
  end

  def update_params
    params.require(:backend_api_config).permit(:path)
  end

  def authorize
    authorize! :manage, BackendApiConfig
  end
end
