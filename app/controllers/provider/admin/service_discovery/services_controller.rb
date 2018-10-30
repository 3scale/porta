# frozen_string_literal: true

class Provider::Admin::ServiceDiscovery::ServicesController < Provider::Admin::BaseController
  before_action :autorize_create, only: :create
  before_action :autorize_update, only: :update

  load_and_authorize_resource :service, through: :current_user,
    through_association: :accessible_services, only: %i[update]

  def create
    if can_create?
      @service = ::ServiceDiscovery::ImportClusterDefinitionsService.create_service(current_account, cluster_namespace: create_service_params[:namespace],
                                                                                                     cluster_service_name: create_service_params[:name])
      flash[:notice] = 'The service will be imported shortly. You will receive a notification when it is done.'
      redirect_to provider_admin_dashboard_path
    else
      flash[:error] = 'Cannot create service.'
      redirect_to admin_new_service_path
    end
  end

  def update
    if @service.discovered? && ::ServiceDiscovery::ImportClusterDefinitionsService.refresh_service(@service)
      flash[:notice] =  'Service information will be updated shortly.'
    else
      flash[:error] =  'Cannot update service.'
    end

    redirect_back_or_to admin_service_metrics_path(@service)
  end

  private

  def create_service_params
    params.require(:service).permit(:name, :namespace)
  end

  def can_create?
    can? :create, Service
  end

  def autorize_create
    authorize! :manage, :plans
  end

  def autorize_update
    authorize! :admin, :plans
  end
end
