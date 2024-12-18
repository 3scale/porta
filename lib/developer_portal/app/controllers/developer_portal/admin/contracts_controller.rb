class DeveloperPortal::Admin::ContractsController < DeveloperPortal::BaseController
  include ::DeveloperPortal::ControllerMethods::PlanChangesMethods

  def update
    application = current_account.contracts.find(params[:id])
    plan = current_account.provider_account.provided_plans.find(params[:plan_id])
    # FIXME: buyer_changes_plan! should return a error/success code
    flash[:notice] = application.buyer_changes_plan!(plan)

    redirect_on_plan_changes(application)
  end

  protected

  # TODO: investigate whether we need to allow other hosts
  def redirect_on_plan_changes(application)
    if plan_changes?
      unstore_plan_change!(application.id)
      redirect_to(admin_application_path(application), allow_other_host: true)
    else
      redirect_back_or_to(admin_application_path(application), allow_other_host: true)
    end
  end
end
