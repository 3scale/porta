# frozen_string_literal: true

class Admin::Api::ServiceSubscriptionsController < Admin::Api::ServiceBaseController
  wrap_parameters ServiceContract, name: :service_subscription
  represents :json, entity: ::ServiceSubscriptionRepresenter, collection: ::ServiceSubscriptionsRepresenter::JSON
  represents :xml, entity: ::ServiceSubscriptionRepresenter, collection: ::ServiceSubscriptionsRepresenter::XML

  before_action :deny_on_premises_for_master
  before_action :authorize_service_plans!

  # Service Subscription Create
  # POST /admin/api/accounts/:account_id/service_subscriptions.xml
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

  # Service Subscription Change Plan
  # PUT /admin/api/accounts/{account_id}/service_contracts/{id}/change_plan.xml
  def change_plan
    service_contract.change_plan(service_plan)
    respond_with(service_contract, serialize: service_plan, representer: ServicePlanRepresenter)
  end

  # Service Subscription Show
  # GET /admin/api/accounts/:account_id/service_contracts/:id.xml
  def show
    respond_with service_subscription
  end

  private

  def account
    @account ||= current_account.buyers.find params.require(:account_id)
  end

  def service_subscription
    @service_subscription ||= account.bought_service_contracts.find(params.require(:id))
  end

  def service_plan
    @service_plan ||= ServicePlan.provided_by(current_account).find(service_subscription_plan_id)
  end

  def service_subscription_plan_id
    @service_subscription_plan_id ||= service_subscription_params[:plan_id]
  end

  def service_subscription_params
    @service_subscription_params ||= params.permit(service_subscription: [:plan_id]).fetch(:service_subscription)
  end
end
