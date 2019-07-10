# frozen_string_literal: true

class Provider::Admin::BackendApisController < Provider::Admin::BaseController
  before_action :ensure_provider_domain
  before_action :find_backend_api, only: :show

  activate_menu :backend_api
  layout 'provider'

  def index
    @backend_apis = current_account.backend_apis
  end

  def show
    activate_menu :backend_api, :overview
  end

  protected

  def find_backend_api
    @backend_api = current_account.backend_apis.find(params[:id])
  end
end
