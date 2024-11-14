# frozen_string_literal: true

class Admin::Api::Personal::AccessTokensController < Admin::Api::Personal::BaseController
  # This needs to be done this way to don't conflict because we have 2 access_token params, the query param for authentication and the body param for create.
  wrap_parameters AccessToken, name: :token

  representer AccessToken

  # Personal Access Token Create
  # POST /admin/api/personal/access_tokens.json
  def create
    respond_with current_user.access_tokens.create(access_token_params)
  end

  # Personal Access Token List
  # GET /admin/api/personal/access_tokens.json
  def index
    respond_with current_user.access_tokens.by_name(params[:name])
  end

  # Personal Access Token Delete
  # DELETE /admin/api/personal/access_tokens/{id}.json
  def destroy
    token.destroy
    respond_with token
  end

  # Personal Access Token Read
  # GET /admin/api/personal/access_tokens/{id}.json
  def show
    respond_with token
  end


  private

  def token
    @token ||= current_user.access_tokens.find_from_id_or_value!(params[:id])
  end

  def access_token_params
    params.require(:token).permit(:name, :permission, :expires_at, scopes: [])
  end
end
