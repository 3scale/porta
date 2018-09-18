# This will publish/hide all kinds of plans. AHEM.
class Api::PlansController < Api::PlansBaseController
  before_action :find_plan
  before_action :deny_on_premises_for_master, only: %i[publish hide]

  def publish
    if @plan.publish
      flash[:notice] = "Plan #{@plan.name} was published."
    else
      flash[:alert]  = "Plan #{@plan.name} cannot be published."
    end

    redirect_back_or_to determine_plans_path
  end

  def hide
    if @plan.hide
      flash[:notice] = "Plan #{@plan.name} was hidden."
    else
      flash[:alert]  = "Plan #{@plan.name} cannot be hidden."
    end

    redirect_back_or_to determine_plans_path
  end

  private
    def collection
      current_account.provided_plans
    end

    def determine_plans_path
      case @plan.type
      when "ServicePlan"
        admin_service_service_plans_path @plan.service
      when "ApplicationPlan"
        admin_service_application_plans_path @plan.service
      when "AccountPlan"
        admin_account_plans_path
      else
        :back # let it fail.
      end
    end

end
