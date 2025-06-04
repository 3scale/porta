# frozen_string_literal: true

class Buyers::CustomAccountPlansController < Buyers::CustomPlansController
  def create
    plan = @contract.customize_plan!(params[:account_plan] || {})

    if plan.persisted?
      redirect_to edit_admin_account_plan_path(plan), notice: 'Plan customized'
    else
      flash.now[:error] = "Plan can't be customized" # TODO: is this ever going to happen?
    end
  end

  def destroy
    @contract.decustomize_plan!
    flash[:notice] = "The plan was set back to #{@contract.plan.name}."
    redirect_to admin_buyers_account_url(@contract.buyer)
  end
end
