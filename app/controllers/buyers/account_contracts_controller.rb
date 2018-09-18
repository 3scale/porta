class Buyers::AccountContractsController < FrontendController

  include ProviderRequirements
  require_provider_user

  before_action :find_buyer, :find_plan

  def update
    @buyer.bought_account_contract.provider_changes_plan!(@plan)
    flash[:notice] = "Plan changed to '#{@plan.name}'."
    redirect_to admin_buyers_account_url(@buyer)
  end

  def find_buyer
    @buyer ||= current_account.buyer_accounts.find(params[:id])
  end

  def find_plan
    @plan = current_account.account_plans.find(params[:account_contract][:plan_id])
  end

end
