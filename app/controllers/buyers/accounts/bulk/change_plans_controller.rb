class Buyers::Accounts::Bulk::ChangePlansController < Buyers::Accounts::Bulk::BaseController

  before_action :authorize_account_plans

  def new
    @plans = current_account.account_plans.not_custom.alphabetically
  end

  def create
    @plan = current_account.account_plans.find_by_id params[:change_plans][:plan_id]
    return unless @plan

    @errors = []

    @accounts.each do |account|
      contract = account.bought_account_contract

      unless contract.change_plan(@plan)
        @errors << account
      end
    end

    handle_errors
  end

  def authorize_account_plans
    authorize! :manage, :account_plans
  end

end
