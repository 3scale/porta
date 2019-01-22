# frozen_string_literal: true

class Admin::Api::Personal::AccessTokensController < Admin::Api::Personal::BaseController
  # This needs to be done this way to don't conflict because we have 2 access_token params, the query param for authentication and the body param for create.
  wrap_parameters AccessToken, name: :token

  representer AccessToken

  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/personal/access_tokens.json"
  ##~ e.responseClass = "access_token"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary   = "Personal Access Token Create"
  ##~ op.description = "Creates an access token. Make sure to copy your new personal access token now. You will not be able to see it again as it is not stored for security reasons."
  ##~ op.group = "access_token"
  #
  ##~ op.parameters.add :name => "name", :description => "Name of the access token.", :dataType => "string", :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "permission", :description => "Permission of the access token. It must be either 'ro' (read only) or 'rw' (read and write).", :dataType => "string", :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "scopes", :defaultName => "scopes[]", :description => "Scope of the access token. URL-encoded array containing one or more of the possible values. The possible values are, for a master user [\"account_management\", \"stats\"], and for a tenant user [\"finance\", \"account_management\", \"stats\"]", :dataType => "custom", :allowMultiple => true, :required => true, :paramType => "query"
  #
  ##~ op.parameters.add @parameter_access_token
  #
  def create
    respond_with current_user.access_tokens.create(access_token_params)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/personal/access_tokens.json"
  ##~ e.responseClass = "List[access_token]"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary   = "Personal Access Token List"
  ##~ op.description = "Returns the list of access tokens of the user. If the parameter name is sent, it returns only those whose name contain the string of the param"
  ##~ op.group = "access_token"
  #
  ##~ op.parameters.add :name => "name", :description => "Part of the name of the access token.", :dataType => "string", :required => false, :paramType => "query"
  #
  ##~ op.parameters.add @parameter_access_token
  #
  def index
    respond_with current_user.access_tokens.by_name(params[:name])
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/personal/access_tokens/{id}.json"
  ##~ e.responseClass = "access_token"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary    = "Personal Access Token Delete"
  ##~ op.description = "Deletes an access token."
  ##~ op.group = "access_token"
  #
  ##~ op.parameters.add :name => "id", :description => "ID or value of the access token.", :dataType => "integer", :paramType => "path", :required => true
  #
  ##~ op.parameters.add @parameter_access_token
  #
  def destroy
    token.destroy
    respond_with token
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/personal/access_tokens/{id}.json"
  ##~ e.responseClass = "access_token"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Personal Access Token Read"
  ##~ op.description = "Shows an access token."
  ##~ op.group = "access_token"
  #
  ##~ op.parameters.add :name => "id", :description => "ID or value of the access token.", :dataType => "integer", :paramType => "path", :required => true
  #
  ##~ op.parameters.add @parameter_access_token
  #
  def show
    respond_with token
  end


  private

  def token
    @token ||= current_user.access_tokens.find_from_id_or_value!(params[:id])
  end

  def access_token_params
    params.require(:token).permit(:name, :permission, scopes: [])
  end
end
