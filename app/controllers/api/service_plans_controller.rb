# frozen_string_literal: true

class Api::ServicePlansController < Api::PlansBaseController
  before_action :authorize_service_plans!

  before_action :activate_sidebar_menu

  activate_menu :serviceadmin, :subscriptions, :service_plans
  sublayout 'api/service'

  def index
    @new_plan = ServicePlan
  end

  def new
    @plan = collection.build params[:service_plan]
  end

  def edit
    @plan || raise(ActiveRecord::RecordNotFound)
  end

  # class super metod which is Api::PlansBaseController#create
  # to create plan same way as all plans
  #
  def create
    super create_service_plan_params
  end

  def update
    super update_service_plan_params do
      redirect_to plans_index_path, :notice => "Service plan updated."
    end
  end

  def destroy
    super
  end

  def masterize
    generic_masterize_plan(@service, :default_service_plan)
  end

  protected

  DEFAULT_PARAMS = %i[name state setup_fee cost_per_month trial_period_days cancellation_period approval_required].freeze

  def activate_sidebar_menu
    activate_menu :sidebar => :service_plans
  end

  def collection(service_id = params[:service_id].presence)
    # start of our scope is current_account
    scope = current_account
    # if we have :service_id, then lookup service first
    scope = scope.accessible_services.find(service_id) if service_id
    # then return all service plans of current scope
    scope.service_plans
  end

  def authorize_service_plans!
    authorize! :manage, :service_plans
  end

  def create_service_plan_params
    params.require(:service_plan).permit(DEFAULT_PARAMS | %i[system_name])
  end

  def update_service_plan_params
    params.require(:service_plan).permit(DEFAULT_PARAMS)
  end
end
