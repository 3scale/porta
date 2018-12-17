# frozen_string_literal: true

class Admin::Api::AccessTokensController < Admin::Api::BaseController
  clear_respond_to
  respond_to :json

  representer AccessToken

  # FIXME: make the name :access_token, but then it clashes with :access_token query param
  # somehow we have to split query and body parameters
  wrap_parameters AccessToken, name: :token

  before_action :authorize_access_tokens

  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/users/{user_id}/access_tokens.json"
  ##~ e.responseClass = "access_token"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary   = "Access Token Create"
  ##~ op.description = "Creates an access token."
  ##~ op.group = "access_token"
  #
  ##~ op.parameters.add :name => "user_id", :description => "ID of the user.", :dataType => "integer", :paramType => "path", :required => true
  ##~ op.parameters.add :name => "name", :description => "Name of the access token.", :dataType => "string", :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "permission", :description => "Permission of the access token. It must be either 'ro' (read only) or 'rw' (read and write).", :dataType => "string", :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "scopes", :defaultName => "scopes[]", :description => "Scope of the access token. URL-encoded array containing one or more of the possible values values. The possible values are, for a master user [\"account_management\", \"stats\"], and for a tenant user [\"finance\", \"account_management\", \"stats\"]", :dataType => "custom", :allowMultiple => true, :required => true, :paramType => "query"
  #
  ##~ op.parameters.add @parameter_access_token
  #
  def create
    access_token = user.access_tokens.create(access_token_params)
    respond_with access_token
  end

  protected

  def access_token_params
    params.require(:token).permit(:name, :permission, scopes: [])
  end

  def authorize_access_tokens
    return unless current_user # # provider_key auth has no user

    authorize! :manage, :access_tokens, user
  end

  def user
    @_user = current_account.users.find(params.require(:user_id))
  end

end
