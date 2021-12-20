# frozen_string_literal: true

class Buyers::Accounts::Bulk::ChangePlansController < Buyers::Accounts::Bulk::BaseController

  before_action :authorize_account_plans

  def new
    @plans = current_account.account_plans.not_custom.alphabetically
  end

  def create
    @plan = current_account.account_plans.find_by(id: plan_id_param)
    return unless @plan

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

  private

  def plan_id_param
    params.require(:change_plan).require(:plan_id)
  end
end
