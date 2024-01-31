# frozen_string_literal: true

class Admin::Api::ServiceContractsController < Admin::Api::ServiceBaseController
  wrap_parameters ServiceContract
  representer ServiceContract

  before_action :deny_on_premises_for_master
  before_action :authorize_service_plans!
  before_action :find_account

  # Service Subscription Create
  # POST /admin/api/accounts/:account_id/service_contracts.xml
  def create
    plan = service_plan

    unless @account
      render_error('Buyer not found with this account ID', status: :unprocessable_entity)
      return
    end

    unless valid_plan_and_account?(plan)
      render_error('Invalid service plan or account id', status: :unprocessable_entity)
      return
    end

    create_service_contract(plan)
  end

  # Service Subscription List
  # GET /admin/api/accounts/{account_id}/service_contracts.xml
  def index
    respond_with @account.bought_service_contracts
  end

  # Service Subscription Delete
  # DELETE /admin/api/accounts/{account_id}/service_contracts/{id}.xml
  def destroy
    service_subscription = ServiceSubscriptionService.new(@account)

    respond_with(service_subscription.unsubscribe(service_contract))
  end

  # Service Subscription Update
  # PUT /admin/api/accounts/{account_id}/service_contracts/{id}.xml
  def update
    service = service_contract.issuer
    new_plan = service.service_plans.find(service_contract_plan_id)
    service_contract.change_plan!(new_plan)
    respond_with(service_contract)
  end

  protected

  def find_account
    @account ||= current_account.buyers.find_by(id: params.require(:account_id))
  end

  def service_contract
    @service_contract ||= @account.bought_service_contracts.find params.require(:id)
  end

  def service_contract_params
    params.permit(service_contract: [:plan_id])
          .fetch(:service_contract).merge(plan: service_plan)
  end

  def service_plan
    ServicePlan.find_by(id: service_contract_plan_id)
  end

  def create_service_contract(plan)
    service_contract = @account.bought_service_contracts.create(service_contract_params.merge(plan: plan))
    respond_with service_contract
  end

  def service_contract_plan_id
    params[:service_contract][:plan_id]
  end

  def valid_plan_and_account?(plan)
    plan && @account.provider_account_id == plan.service.account_id
  end
end
