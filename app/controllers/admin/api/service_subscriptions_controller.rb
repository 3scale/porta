# frozen_string_literal: true

class Admin::Api::ServiceSubscriptionsController < Admin::Api::ServiceBaseController
  wrap_parameters ServiceContract, name: :service_subscription
  representer entity: ::ServiceSubscriptionRepresenter, collection: ::ServiceSubscriptionsRepresenter

  before_action :deny_on_premises_for_master
  before_action :authorize_service_plans!

  # Service Subscription Create
  # POST /admin/api/accounts/:account_id/service_subscriptions.json
  def create
    respond_with account.bought_service_contracts.create(plan: service_plan)
  end

  # Service Subscription List
  # GET /admin/api/accounts/{account_id}/service_subscriptions.json
  def index
    respond_with account.bought_service_contracts
  end

  # Service Subscription Delete
  # DELETE /admin/api/accounts/{account_id}/service_subscriptions/{id}.json
  def destroy
    service = ServiceSubscriptionService.new(account)

    respond_with(service.unsubscribe(service_subscription))
  end

  # Service Subscription Change Plan
  # PUT /admin/api/accounts/{account_id}/service_subscriptions/{id}/change_plan.json
  def change_plan
    service_subscription.change_plan(service_plan)
    respond_with(service_subscription, serialize: service_plan, representer: ServicePlanRepresenter)
  end

  # Service Subscription Show
  # GET /admin/api/accounts/:account_id/service_subscriptions/:id.json
  def show
    respond_with service_subscription
  end

  # Service Subscription Approve
  # PUT /admin/api/accounts/{account_id}/service_subscriptions/{id}/approve.json
  def approve
    service_subscription.accept
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
