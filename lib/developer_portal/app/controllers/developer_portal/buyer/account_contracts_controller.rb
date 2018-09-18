class DeveloperPortal::Buyer::AccountContractsController < DeveloperPortal::BaseController

  before_action :find_plan, :find_contract

  def update
    if msg = @contract.buyer_changes_plan!(@plan)
      flash[:message] = msg
    else
      flash[:error] = "Cannot be saved"
    end
    redirect_to admin_account_account_plans_path
  end

  private

  def find_contract
    @contract = current_account.bought_account_contract
  end

  def find_plan
    @plan = current_account.provider_account.account_plans.published.find(params[:plan_id])
  end
end
