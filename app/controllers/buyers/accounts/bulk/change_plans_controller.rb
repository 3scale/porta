# frozen_string_literal: true

class Buyers::Accounts::Bulk::ChangePlansController < Buyers::Accounts::Bulk::BaseController

  before_action :authorize_account_plans

  helper_method :plans

  def new; end

  def create
    return unless (plan = current_account.account_plans.find_by(id: plan_id_param))

    accounts.reject { |account| account.bought_account_contract.plan_id == plan.id }
            .each do |account|
              @errors << account unless account.bought_account_contract.change_plan(plan)
            end

    handle_errors
    super
  end

  def authorize_account_plans
    authorize! :manage, :account_plans
  end

  private

  def plans
    @plans ||= current_account.account_plans.not_custom.alphabetically
  end
end
