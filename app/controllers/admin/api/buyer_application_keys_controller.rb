class Admin::Api::BuyerApplicationKeysController < Admin::Api::BuyersBaseController
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path          = "/admin/api/accounts/{account_id}/applications/{application_id}/keys.xml"
  ##~ e.responseClass = "application"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Application Key List"
  ##~ op.description = "Lists the Application Keys (or the Client Secret for OAuth or OpenID Connect modes) of the application."
  ##~ op.group = "application"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id_name
  ##~ op.parameters.add @parameter_application_id_by_id_name
  #
  def index
    respond_with(application_keys, representer: ApplicationKeysRepresenter)
  end

  ##~ op            = e.operations.add
  ##~ op.nickname   = "key_create"
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "Application Key Create"
  ##~ op.description = "Adds an application key for App Id/App Key mode (until a maximum of 5 keys) or the Client Secret for OAuth or OpenID Connect modes (only one)."
  ##~ op.group = "application"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id_name
  ##~ op.parameters.add @parameter_application_id_by_id_name
  ##~ op.parameters.add :name => "key", :description => "app_key to be added", :dataType => "string", :required => true, :paramType => "query"
  #
  def create
    key = application_keys.add(params[:key])

    respond_with(key, serialize: application)
  end

  ##~ e = sapi.apis.add
  ##~ e.path          = "/admin/api/accounts/{account_id}/applications/{application_id}/keys/{key}.xml"
  ##~ e.responseClass = "application"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary    = "Application Key Delete"
  ##~ op.description = "Deletes an application key for App Id/App Key mode or the Client Secret for OAuth or OpenID Connect modes. An application may have to have at least one App Key (controlled by settings)."
  ##~ op.group = "application"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id_name
  ##~ op.parameters.add @parameter_application_id_by_id_name
  ##~ op.parameters.add :name => "key", :description => "app_key to be deleted.", :dataType => "string", :required => true, :paramType => "path"
  #
  def destroy
    key = application_keys.remove!(params[:key] || params[:id])

    respond_with(key, serialize: application)
  end

  protected

  def application
    @application ||= accessible_bought_cinstances.find(params[:application_id])
  end

  def application_keys
    @application_keys ||= application.application_keys
  end

end
