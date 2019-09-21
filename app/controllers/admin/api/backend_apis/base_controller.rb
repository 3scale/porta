# frozen_string_literal: true

class Admin::Api::BackendApis::BaseController < Admin::Api::BaseController
  self.access_token_scopes = :account_management

  before_action :authorize

  clear_respond_to
  respond_to :json

  private

  def backend_api
    @backend_api ||= current_account.backend_apis.find(params[:backend_api_id])
  end

  def authorize
    authorize! :manage, BackendApi
  end
end
