# frozen_string_literal: true

class Admin::Api::BackendApis::BaseController < Admin::Api::BaseController
  self.access_token_scopes = :account_management

  before_action :authorize

  clear_respond_to
  respond_to :json

  paginate only: :index

  private

  def backend_api
    @backend_api ||= current_account.backend_apis.accessible.find(params.require(:backend_api_id))
  end

  def authorize
    return unless current_user # provider_key access
    authorize! :edit, BackendApi
  end
end
