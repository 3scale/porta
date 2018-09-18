# frozen_string_literal: true

class Master::Api::Finance::BillingJobsController < Master::Api::Finance::BaseController

  include Finance::ControllerRequirements
  include Finance::BillingDates::ControllerMethods

  before_action :verify_write_permission, only: [:create]
  before_action { finance_module_required(provider) }

  ##~ sapi = source2swagger.namespace("Master API")
  #
  ##~ @base_path = ""
  #
  ##~ sapi.basePath     = @base_path
  ##~ sapi.swaggerVersion = "0.1a"
  ##~ sapi.apiVersion   = "1.0"
  ##~
  ##~ e = sapi.apis.add
  ##~ e.path = "/master/api/providers/{provider_id}/billing_jobs.xml"
  #
  ##~ op             = e.operations.add
  ##~ op.httpMethod  = "POST"
  ##~ op.summary     = "Trigger Billing"
  ##~ op.description = "Triggers billing process for all developer accounts."
  ##~ op.nickname    = "trigger_tenant_billing"
  ##~ op.group       = "finance"
  #
  ##~ @parameter_tenant_id_by_id_name = {:name => "provider_id", :description => "ID of the tenant account.", :dataType => "int", :required => true, :paramType => "path", :threescale_name => "account_ids"}
  ##~ @parameter_date = {:name => "date", :description => "Base date for the billing process. Format YYYY-MM-DD (UTC).", :dataType => "string", :required => true, :paramType => "query" }
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_tenant_id_by_id_name
  ##~ op.parameters.add @parameter_date
  #
  def create
    Finance::BillingService.async_call(provider, billing_date)
    render nothing: true, status: :accepted
  end

  private

  def provider
    @provider ||= Account.providers.find(billing_params[:provider_id])
  end

  def billing_params
    @billing_params ||= params.permit(:provider_id, :account_id, :date)
  end
end
