class Admin::Api::ProvidersController < Admin::Api::BaseController

  wrap_parameters Account

  representer ::Account

  # swagger
  #
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ sapi.basePath     = @base_path
  #
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/provider.xml"
  ##~ e.responseClass = "account"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary = "Provider Account Read"
  ##~ op.description = "Returns your account."
  ##~ op.group = "provider"
  ##~ op.parameters.add @parameter_access_token
  #
  def show
    respond_with current_account
  end

  # swagger
  #
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ sapi.basePath     = @base_path
  #
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/provider.xml"
  ##~ e.responseClass = "provider"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary = "Provider Account Update"
  ##~ op.description = "Updates email addresses used to deliver email notifications to customers."
  ##~ op.group = "account"
  #
  ##~ @parameter_from_email = {:name => "from_email", :description => "New outgoing email.", :dataType => "string", :paramType => "query"}
  ##~ @parameter_support_email = {:name => "support_email", :description => "New support email.", :dataType => "string", :paramType => "query"}
  ##~ @parameter_finance_support_email = {:name => "finance_support_email", :description => "New finance support email.", :dataType => "string", :paramType => "query"}
  ##~ @parameter_site_access_code = {:name => "site_access_code", :description => "Developer Portal Access Code.", :dataType => "string", :paramType => "query"}
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_from_email
  ##~ op.parameters.add @parameter_support_email
  ##~ op.parameters.add @parameter_finance_support_email
  ##~ op.parameters.add @parameter_site_access_code
  #
  def update
    current_account.update_attributes(provider_params, without_protection: true)
    respond_with current_account
  end

  protected

  def provider_params
    params.required(:account).permit(:from_email, :support_email, :finance_support_email, :site_access_code)
  end
end
