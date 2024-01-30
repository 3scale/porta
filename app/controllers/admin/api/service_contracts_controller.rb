# frozen_string_literal: true

class Admin::Api::ServiceContractsController < Admin::Api::ServiceBaseController
  wrap_parameters ServiceContract
  representer ServiceContract

  before_action :deny_on_premises_for_master
  before_action :authorize_service_plans!
  before_action :find_service, only: %i[create]

  # Service Subscription Create
  # POST /admin/api/accounts/:account_id/service_contracts.xml
  def create
    service_contract = account.bought_service_contracts.create(service_contract_params)
    respond_with service_contract
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
    service = service_contract.issuer
    new_plan = service.service_plans.find(service_contract_plan_id)
    service_contract.change_plan!(new_plan)
    respond_with(service_contract)
  end

  protected

  def account
    @account ||= current_account.buyers.find params.require(:account_id)
  end

  def find_service
    @service = service
  end

  def service_contract
    @service_contract ||= account.bought_service_contracts.find params.require(:id)
  end

  def service_contract_params
    params.permit(service_contract: [:plan_id])
          .fetch(:service_contract).merge(plan: service_plan)
  end

  def service
    service ||= accessible_services.find(params[:service_id])
  end

  def service_plan(plan_id = service_contract_plan_id)
    @service_plan ||= service.service_plans.find_by(id: plan_id)
  end

  def service_contract_plan_id
    params[:service_contract][:plan_id]
  end
end
