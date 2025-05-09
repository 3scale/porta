# frozen_string_literal: true

class Provider::Admin::ServiceDiscovery::ServicesController < Provider::Admin::BaseController
  before_action :deny_on_premises_for_master
  before_action :authorize_section
  before_action :autorize_action, only: :create
  load_and_authorize_resource :service, through: :current_user, through_association: :accessible_services, only: %i[update]

  def create
    if can_create?
      @service = ::ServiceDiscovery::ImportClusterDefinitionsService.create_service(current_account, cluster_namespace: create_service_params[:namespace],
                                                                                                     cluster_service_name: create_service_params[:name], user: current_user)
      redirect_to provider_admin_dashboard_path, success: t('.success')
    else
      redirect_to admin_new_service_path, danger: t('.error')
    end
  end

  def update
    if @service.discovered? && ::ServiceDiscovery::ImportClusterDefinitionsService.refresh_service(@service, user: current_user)
      flash[:success] =  t('.success')
    else
      flash[:danger] =  t('.error')
    end

    redirect_back_or_to admin_service_metrics_path(@service)
  end

  private

  def create_service_params
    params.require(:service).permit(:name, :namespace)
  end

  def authorize_section
    authorize! :manage, :plans
  end

  def autorize_action
    return if current_user.admin? # We want to postpone for admins so we can use #can_create? and provide better error messages
    authorize! action_name.to_sym, Service
  end

  def can_create?
    can? :create, Service
  end
end
