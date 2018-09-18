class Admin::Api::BuyerApplicationReferrerFiltersController < Admin::Api::BuyersBaseController

  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path          = "/admin/api/accounts/{account_id}/applications/{application_id}/referrer_filters.xml"
  ##~ e.responseClass = "application"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Application Referrer Filter List"
  ##~ op.description = "Lists referrer filters of the application."
  ##~ op.group = "application"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id_name
  ##~ op.parameters.add @parameter_application_id_by_id_name
  #

  def index
    respond_with(referrer_filters, representer: ReferrerFiltersRepresenter)
  end

  ##~ op            = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "Application Referrer Filter Create"
  ##~ op.description = "Adds a referrer filter to an application. Referrer filters limit API requests by domain or IP ranges."
  ##~ op.group = "application"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id_name
  ##~ op.parameters.add @parameter_application_id_by_id_name
  ##~ op.parameters.add :name => "referrer_filter", :description => "Referrer filter to be created.", :dataType => "string", :required => true, :paramType => "query"
  #
  def create
    referrer_filter = referrer_filters.add(params[:referrer_filter])
    respond_with(referrer_filter, serialize: application)
  end

  # swagger
  ##~ e = sapi.apis.add
  ##~ e.path          = "/admin/api/accounts/{account_id}/applications/{application_id}/referrer_filters/{id}.xml"
  ##~ e.responseClass = "application"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary    = "Application Referrer Filter Delete"
  ##~ op.description = "Deletes a referrer filter of an application. Referrer filters limit API requests by domain or IP ranges."
  ##~ op.group = "application"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id_name
  ##~ op.parameters.add @parameter_application_id_by_id_name
  ##~ op.parameters.add :name => "id", :description => "ID of referrer filter to be deleted.", :dataType => "int", :required => true, :paramType => "path"
  #
  def destroy
    referrer_filter.destroy
    respond_with(referrer_filter, serialize: application)
  end

  protected

  def application
    @application ||= accessible_bought_cinstances.find(params[:application_id])
  end

  def referrer_filters
    @referrer_filters ||= application.referrer_filters
  end

  def referrer_filter
    @referrer_filter ||= referrer_filters.find(params[:id])
  end
end
