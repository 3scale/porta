# frozen_string_literal: true

class Api::ApplicationPlansController < Api::PlansBaseController
  before_action :activate_sidebar_menu

  activate_menu :serviceadmin, :applications, :application_plans
  sublayout 'api/service'

  def index
    @new_plan = ApplicationPlan
  end

  def new
    @plan = collection.build params[:application_plan]
  end

  def edit
    @plan = collection.includes(:plan_metrics, :usage_limits, :pricing_rules, service: :top_level_metrics).find(params[:id])
  end

  # class super metod which is Api::PlansBaseController#create
  # to create plan same way as all plans
  #
  def create
    super(application_plan_params)
  end

  def update
    super(application_plan_params)
  end

  def destroy
    super
  end

  def masterize
    assign_plan!(@service, :default_application_plan)
    flash[:notice] = 'The default plan has been changed.'
    redirect_to admin_service_application_plans_path(@service)
  end

  protected

  def scope
    @service || current_account
  end

  def collection
    scope.application_plans.includes(:issuer)
  end

  def activate_sidebar_menu
    activate_menu :sidebar => :application_plans
  end

  def application_plan_params
    params.require(:application_plan).permit(:name, :system_name, :description, :rights, :approval_required, :trial_period_days, :cost_per_month, :setup_fee)
  end
end
