# frozen_string_literal: true

class Api::BackendApiConfigsController < Api::BaseController
  load_and_authorize_resource :service, through: :current_user, through_association: :accessible_services

  before_action :authorize

  activate_menu :serviceadmin, :integration
  sublayout 'api/service'

  def new
    @backend_api_config = service.backend_api_configs.build
  end

  def create
    @backend_api_config = service.backend_api_configs.build(backend_api_params)

    if @backend_api_config.save
      flash[:notice] = 'Backend API added to product.'
      redirect_to edit_admin_service_integration_path(@service)
    else
      flash[:error] = "Couldn't add Backend API to product"
      render 'new'
    end
  end

  protected

  def authorize
    authorize! :manage, BackendApiConfig
  end

  attr_reader :service

  delegate :backend_api_configs, to: :service

  def backend_api_params
    params.require(:backend_api_config).permit(:backend_api_id, :path)
  end
end
