# frozen_string_literal: true

class Admin::Api::ServiceContractsController < Admin::Api::ServiceBaseController
  wrap_parameters ServiceContract
  representer ServiceContract
  represents :json, entity: ::ServiceContractRepresenter, collection: ::ServiceContractsRepresenter::JSON
  represents :xml, entity: ::ServiceContractRepresenter, collection: ::ServiceContractsRepresenter::XML

  before_action :deny_on_premises_for_master
  before_action :authorize_service_plans!

  # Service Subscription Create
  # POST /admin/api/accounts/:account_id/service_contracts.xml
  def create
    respond_with account.bought_service_contracts.create(plan: service_plan)
  end

  # Service Subscription List
  # GET /admin/api/accounts/{account_id}/service_contracts.xml
  def index
    respond_with account.bought_service_contracts
  end

  # Service Subscription Delete
  # DELETE /admin/api/accounts/{account_id}/service_contracts/{id}.xml
  def destroy
    service_subscription = ServiceSubscriptionService.new(account)

    respond_with(service_subscription.unsubscribe(service_contract))
  end

  # Service Subscription Update
  # PUT /admin/api/accounts/{account_id}/service_contracts/{id}.xml
  def update
    service_contract.change_plan!(service_plan)
    respond_with(service_contract)
  end

  # Service Subscription Show
  # GET /admin/api/accounts/:account_id/service_contracts/:id.xml
  def show
    respond_with service_contract
  end

  private

  def account
    @account ||= current_account.buyers.find params.require(:account_id)
  end

  def service_contract
    @service_contract ||= account.bought_service_contracts.find(params.require(:id))
  end

  def service_plan
    @service_plan ||= ServicePlan.provided_by(current_account).find(service_contract_plan_id)
  end

  def service_contract_plan_id
    @service_contract_plan_id ||= service_contract_params[:plan_id]
  end

  def service_contract_params
    @service_contract_params ||= params.permit(service_contract: [:plan_id]).fetch(:service_contract)
  end
end
