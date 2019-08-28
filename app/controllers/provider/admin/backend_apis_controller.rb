# frozen_string_literal: true

class Provider::Admin::BackendApisController < Provider::Admin::BaseController
  before_action :find_backend_api, except: %i[index new create]
  before_action :authorize

  activate_menu :backend_api, :overview
  layout 'provider'

  def index
    @backend_apis = current_account.backend_apis
  end

  def new
    activate_menu :dashboard
    @backend_api = collection.build params[:backend_api]
  end

  def create
    @backend_api = current_account.backend_apis.build(backend_api_params)
    if @backend_api.save
      redirect_to provider_admin_backend_api_path(@backend_api), notice: 'Backend API created'
    else
      flash.now[:error] = 'Backend API could not be created'
      activate_menu :dashboard
      render :new
    end
  end

  def show; end

  def edit; end

  def update
    if @backend_api.update_attributes(backend_api_params)
      redirect_to provider_admin_backend_api_path(@backend_api), notice: 'Backend API updated'
    else
      flash.now[:error] = 'Backend API could not be updated'
      render :edit
    end
  end

  def destroy
    # TODO
  end

  protected

  def find_backend_api
    @backend_api = current_account.backend_apis.find(params[:id])
  end

  def backend_api_params
    params.require(:backend_api).permit(:name, :system_name, :description, :private_endpoint)
  end

  def authorize
    authorize! :manage, BackendApi
  end

  def collection
    current_account.backend_apis
  end
end
