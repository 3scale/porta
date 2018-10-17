class Api::ApplicationPlansController < Api::PlansBaseController

  before_action :authorize_manage_plans, only: %i[new create destroy]
  before_action :activate_sidebar_menu
  prepend_before_action :authorize_manage_plans, only: %i[new create destroy]

  with_options :only => [:index, :new, :edit, :create, :update, :destroy, :masterize] do |options|
    options.before_action :find_service
  end

  activate_menu :serviceadmin, :integration, :application_plans
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
    super params[:application_plan]
  end

  def update
    super params[:application_plan]
  end

  def destroy
    super
  end

  def masterize
    generic_masterize_plan(@service, :default_application_plan)
  end

  protected

  def collection
    scope = current_account

    if params[:service_id].present?
      scope = scope.accessible_services.find(params[:service_id])
    end

    scope.application_plans.includes(:issuer)
  end

  def activate_sidebar_menu
    activate_menu :sidebar => :application_plans
  end

  private

  def find_service
    service_id = params[:service_id].presence || @plan.try!(:issuer_id)
    @service   = current_user.accessible_services.find(service_id)

    authorize! :show, @service
  end

end
