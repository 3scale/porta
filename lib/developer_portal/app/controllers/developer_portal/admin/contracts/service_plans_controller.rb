module DeveloperPortal
  class Admin::Contracts::ServicePlansController < DeveloperPortal::BaseController

    layout false
    before_action :find_contract

    def index
      @plans = @contract.service.service_plans.published
      render :template => 'developer_portal/admin/plans_widget/index', :locals => { :contract => @contract }
    end

    private

    def find_contract
      @contract = current_account.bought_service_contracts.find(params[:contract_id])
      @application = @contract
    end

  end
end
