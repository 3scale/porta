# frozen_string_literal: true

class Provider::Admin::BackendApis::BaseController < Provider::Admin::BaseController
  before_action :authorize
  before_action :find_backend_api

  activate_menu :backend_api
  layout 'provider'

  protected

  def find_backend_api
    @backend_api = current_account.backend_apis.accessible.find(params.require(:backend_api_id))
  end

  def authorize
    authorize! :edit, BackendApi
  end
end
