# frozen_string_literal: true

# TODO: rename to CustomAccountPlansController
# buyers/accounts/:id
class Buyers::CustomPlansController < FrontendController
  before_action :find_contract

  def create
    @plan = @contract.customize_plan!(params[:account_plan] || {})

    flash.now[:success] = t('.success') if @plan.persisted?

    respond_to :js
  end

  def destroy
    @contract.decustomize_plan!
    redirect_to admin_buyers_account_url(@contract.buyer), success: t('.success', name: @contract.plan.name)
  end

  private

  def find_contract
    # this is caused by the fact of using the same controller for all contracts
    # first a paranoid check to avoid editing a contract not of provider
    @contract = current_account.provided_contracts.find params[:contract_id]
  end
end
