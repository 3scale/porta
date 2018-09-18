# frozen_string_literal: true

class Admin::Api::ServiceContractsController < Admin::Api::ServiceBaseController
  wrap_parameters ServiceContract
  representer ServiceContract

  before_action :deny_on_premises_for_master
  before_action :authorize_service_plans!


  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/accounts/{account_id}/service_contracts.xml"
  ##~ e.responseClass = "service_contract"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Service Subscription List"
  ##~ op.description = "List all the service_contracts of an account"
  ##~ op.group = "service_contract"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id_name
  #
  def index
    respond_with account.bought_service_contracts
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/accounts/{account_id}/service_contracts/{id}.xml"
  ##~ e.responseClass = "service_contract"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary    = "Service Subscription Delete"
  ##~ op.description = "Unsubscribe from a service. This endpoint will delete all the applications that are under the subscribed service."
  ##~ op.group = "service_contract"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id_name
  ##~ op.parameters.add :name => "id", :description => "ID of the service contract.", :dataType => "int", :required => true, :paramType => "path", :threescale_name => "service_contract_ids"
  #
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
