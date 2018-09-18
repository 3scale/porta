# frozen_string_literal: true

class Admin::Api::AccessTokensController < Admin::Api::BaseController
  clear_respond_to
  respond_to :json

  representer AccessToken

  # FIXME: make the name :access_token, but then it clashes with :access_token query param
  # somehow we have to split query and body parameters
  wrap_parameters AccessToken, name: :token

  before_action :authorize_access_tokens

  def create
    access_token = user.access_tokens.create(access_token_params)

    respond_with access_token
  end

  protected

  def access_token_params
    params.require(:token).permit(:name, :value, :permission, scopes: [])
  end

  def authorize_access_tokens
    return unless current_user # # provider_key auth has no user

    authorize! :manage, :access_tokens, user
  end

  def user
    @_user = current_account.users.find(params.require(:user_id))
  end

end
