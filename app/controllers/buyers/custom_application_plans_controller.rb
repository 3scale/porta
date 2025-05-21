# frozen_string_literal: true

# p/admin/applications/:id
class Buyers::CustomApplicationPlansController < FrontendController
  before_action :find_contract

  def create
    @plan = @contract.customize_plan!(params[:application_plan] || {})

    flash.now[:success] = t('.success') if @plan.persisted?

    respond_to :js
  end

  def destroy
    @contract.decustomize_plan!
    redirect_to provider_admin_application_path(@contract), success: t('.success', name: @contract.plan.name)
  end

  private

  def find_contract
    # this is caused by the fact of using the same controller for all contracts
    # first a paranoid check to avoid editing a contract not of provider
    @contract = current_account.provided_contracts.find params[:contract_id]
  end
end
