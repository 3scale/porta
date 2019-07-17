# frozen_string_literal: true

class Provider::Admin::BackendApisController < Provider::Admin::BaseController
  before_action :find_backend_api, only: :show

  activate_menu :dashboard
  layout 'provider'

  def index
    @backend_apis = current_account.backend_apis
  end

  def show
    activate_menu :serviceadmin, :integration, :configuration
  end

  protected

  def find_backend_api
    @backend_api = current_account.backend_apis.find(params[:id])
  end
end
