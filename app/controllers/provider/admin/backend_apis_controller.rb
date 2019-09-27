# frozen_string_literal: true

class Provider::Admin::BackendApisController < Provider::Admin::BaseController
  before_action :find_backend_api, except: %i[new create]
  before_action :authorize

  activate_menu :backend_api, :overview
  layout 'provider'

  def new
    activate_menu :dashboard
    @backend_api = collection.build params[:backend_api]
  end

  def create
    @backend_api = current_account.backend_apis.build(create_params)
    if @backend_api.save
      redirect_to provider_admin_backend_api_path(@backend_api), notice: 'Backend created'
    else
      flash.now[:error] = 'Backend could not be created'
      activate_menu :dashboard
      render :new
    end
  end

  def show; end

  def edit; end

  def update
    if @backend_api.update_attributes(update_params)
      redirect_to provider_admin_backend_api_path(@backend_api), notice: 'Backend updated'
    else
      flash.now[:error] = 'Backend could not be updated'
      render :edit
    end
  end

  def destroy
    if @backend_api.mark_as_deleted
      redirect_to provider_admin_dashboard_path, notice: 'Backend will be deleted shortly.'
    else
      flash[:error] = 'Backend could not be deleted'
      render :edit
    end
  end

  protected

  DEFAULT_PARAMS = %i[name description private_endpoint].freeze
  private_constant :DEFAULT_PARAMS

  def find_backend_api
    @backend_api = current_account.backend_apis.accessible.find(params[:id])
  end

  def create_params
    params.require(:backend_api).permit(DEFAULT_PARAMS | %i[system_name])
  end

  def update_params
    params.require(:backend_api).permit(DEFAULT_PARAMS)
  end

  def authorize
    authorize! :manage, BackendApi
  end

  def collection
    current_account.backend_apis
  end
end
