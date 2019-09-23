# frozen_string_literal: true

class Api::BackendApiConfigsController < Api::BaseController
  include ThreeScale::Search::Helpers

  load_and_authorize_resource :service, through: :current_user, through_association: :accessible_services

  before_action :authorize
  before_action :find_backend_api_config, only: %i[edit update destroy]
  before_action :ensure_same_account_backend_api, only: :create

  activate_menu :serviceadmin, :integration, :backend_api_configs
  sublayout 'api/service'

  def index
    @backend_api_configs = service.backend_api_configs.order_by(params[:sort], params[:direction])
                                                      .includes(:backend_api)
                                                      .paginate(pagination_params)
  end

  def new
    @backend_api_config = service.backend_api_configs.build
  end

  def create
    @backend_api_config = service.backend_api_configs.build(backend_api_config_params)

    if @backend_api_config.save
      flash[:notice] = 'Backend API added to product.'
      redirect_to admin_service_backend_api_configs_path(@service)
    else
      flash[:error] = "Couldn't add Backend API to product"
      render 'new'
    end
  end

  def edit; end

  def update
    if @backend_api_config.update_attributes(backend_api_config_params.slice(:path))
      redirect_to admin_service_backend_api_configs_path(@service), notice: 'Backend API config was updated.'
    else
      render :edit
    end
  end

  def destroy
    if @backend_api_config.destroy
      flash[:notice] = 'The Backend API was removed from the product'
    else
      flash[:error] = 'The Backend API cannot be removed from the product'
    end

    redirect_to admin_service_backend_api_configs_path(@service)
  end

  protected

  def authorize
    authorize! :manage, BackendApiConfig
  end

  attr_reader :service

  delegate :backend_api_configs, to: :service

  def backend_api_config_params
    params.require(:backend_api_config).permit(:backend_api_id, :path)
  end

  def find_backend_api_config
    @backend_api_config = service.backend_api_configs.find(params[:id])
  end

  def ensure_same_account_backend_api
    current_account.backend_apis.find(backend_api_config_params[:backend_api_id])
  end
end
