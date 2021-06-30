class Buyers::CustomApplicationPlansController < FrontendController

  before_action :find_contract

  def new
  end

  def create
    @plan = @contract.customize_plan!(params[:application_plan] || {})

    respond_to do |format|
      format.js do
        render @plan.persisted? ? :create : :new
      end
    end
  end

  def destroy
    @contract.decustomize_plan!
    flash[:notice] = "The plan was set back to #{@contract.plan.name}."
    redirect_to provider_admin_application_path(@contract)
  end

  private

  def find_contract
    # this is caused by the fact of using the same controller for all contracts
    # first a paranoid check to avoid editing a contract not of provider
    @contract = current_account.provided_contracts.find params[:contract_id]
  end
end
