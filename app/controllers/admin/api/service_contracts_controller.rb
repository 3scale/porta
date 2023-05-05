# frozen_string_literal: true

class Admin::Api::ServiceContractsController < Admin::Api::ServiceBaseController
  wrap_parameters ServiceContract
  representer ServiceContract

  before_action :deny_on_premises_for_master
  before_action :authorize_service_plans!

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

  protected

  def account
    @account ||= current_account.buyers.find params.require(:account_id)
  end

  def service_contract
    @service_contract ||= account.bought_service_contracts.find params.require(:id)
  end

end
