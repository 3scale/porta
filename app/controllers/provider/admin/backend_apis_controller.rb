# frozen_string_literal: true

class Provider::Admin::BackendApisController < Provider::Admin::BaseController
  before_action :find_backend_api, only: %i[show update]
  before_action :authorize, only: %i[create update]

  activate_menu :backend_api
  layout 'provider'

  def index
    @backend_apis = current_account.backend_apis
  end

  def show
    activate_menu :backend_api, :overview
  end

  def create
    backend_api = current_account.backend_apis.build(backend_api_params)
    if backend_api.save
      redirect_to provider_admin_backend_api_path(backend_api), notice: 'Backend API created'
    else
      flash.now[:error] = 'Backend API could not be created'
      render :edit
    end
  end

  def update
    if @backend_api.update_attributes(backend_api_params)
      redirect_to provider_admin_backend_api_path(@backend_api), notice: 'Backend API updated'
    else
      flash.now[:error] = 'Backend API could not be updated'
      render :edit
    end
  end

  protected

  def find_backend_api
    @backend_api = current_account.backend_apis.find(params[:id])
  end

  def backend_api_params
    params.require(:backend_api).permit(:name, :system_name, :description, :private_endpoint)
  end

  def authorize
    authorize! :edit, BackendApi
  end
end
