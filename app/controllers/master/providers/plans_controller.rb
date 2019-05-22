class Master::Providers::PlansController < Master::Providers::BaseController
  respond_to :html
  before_action :find_new_plan
  layout false

  def edit
    @current_plan = @provider.bought_cinstances.first.plan
  end

  def update
    authorize! :update, :provider_plans
    raise CanCan::AccessDenied unless current_user.has_access_to_service?(@new_plan.issuer_id)

    @provider.force_upgrade_to_provider_plan!(@new_plan)
  end

  private


  def find_new_plan
    @new_plan = Account.master.application_plans.stock.find(params[:plan_id])
    @new_switches = @provider.available_plans[@new_plan.system_name]
    render_error "Plan #{@new_plan.name} is not one of the 3scale stock plans. Cannot automatically change to it." unless @new_switches
  end

end
