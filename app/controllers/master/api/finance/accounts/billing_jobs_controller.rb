# frozen_string_literal: true

class Master::Api::Finance::Accounts::BillingJobsController < Master::Api::Finance::BillingJobsController

  before_action :find_account

  ##~ sapi = source2swagger.namespace("Master API")
  #
  ##~ @base_path = ""
  #
  ##~ sapi.basePath     = @base_path
  ##~ sapi.swaggerVersion = "0.1a"
  ##~ sapi.apiVersion   = "1.0"
  ##~
  ##~ e = sapi.apis.add
  ##~ e.path = "/master/api/providers/{provider_id}/accounts/{account_id}/billing_jobs.xml"
  #
  ##~ op             = e.operations.add
  ##~ op.httpMethod  = "POST"
  ##~ op.summary     = "Trigger Billing by Account"
  ##~ op.description = "Triggers billing process for a specific developer account."
  ##~ op.nickname    = "trigger_developer_billing"
  ##~ op.group       = "finance"
  #
  ##~ @parameter_developer_id_by_id_name = {:name => "account_id", :description => "ID of the developer account.", :dataType => "int", :required => true, :paramType => "path"}
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_tenant_id_by_id_name
  ##~ op.parameters.add @parameter_developer_id_by_id_name
  ##~ op.parameters.add @parameter_date
  #
  def create
    Finance::BillingService.async_call(provider, billing_date, buyers_scope)
    render nothing: true, status: :accepted
  end

  private

  def find_account
    @account = provider.buyers.find(billing_params.require(:account_id))
  end

  def buyers_scope
    provider.buyers.where(id: @account.id)
  end
end
