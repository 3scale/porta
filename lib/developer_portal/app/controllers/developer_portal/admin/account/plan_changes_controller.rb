module DeveloperPortal
  class Admin::Account::PlanChangesController < DeveloperPortal::BaseController
    include ::DeveloperPortal::ControllerMethods::PaymentPathsMethods
    include ::DeveloperPortal::ControllerMethods::PlanChangesMethods

    liquify prefix: 'accounts/plan_changes'

    def index
      contracts = contracts_from_store
      plans = plans_from_store.index_by(&:id)

      # FIXME: this looks like not the right place
      changes = contracts.each_with_object([]) do |contract, array|
        plan_id = plan_changes_store[contract.id]
        array << [contract, plans[plan_id]] if plan_id
      end
      assign_drops plan_changes: Liquid::Drops::Collection.for_drop(Liquid::Drops::PlanChange).new(changes)
    end

    def new
      remember_plan_change!
      redirect_to payment_details_path
    end

    def destroy
      forget_plan_change!
      flash[:notice] = 'Plan change cancelled'
      redirect_to admin_application_path(params[:id])
    end

    protected

    def plans_from_store
      current_account.provider_account.application_plans.where(id: plan_changes_store.plan_ids)
    end

    def contracts_from_store
      current_account.application_contracts.includes(:plan).where(id: plan_changes_store.contract_ids)
    end

    def remember_plan_change!
      store_plan_change!(params[:contract_id], params[:plan_id])
    end

    def forget_plan_change!
      unstore_plan_change!(params[:id])
    end
  end
end
