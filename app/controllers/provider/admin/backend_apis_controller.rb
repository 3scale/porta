# frozen_string_literal: true

class Provider::Admin::BackendApisController < Provider::Admin::BaseController
  before_action :find_service, only: :show # FIXME: This should not be here. It's only until we have the BackendApi model defined and moved all the attributes from Service and Proxy

  activate_menu :dashboard
  layout 'provider'

  def index
    # FIXME: Eventually Backend API shall exist independently from services
    @backend_apis = current_account.services.map { |service| BackendApiPresenter.new(service) }
  end

  def show
    # FIXME: Remove any reference to 'service' from here when a Service can have more than 1 Backend API
    @backend_api = BackendApiPresenter.new(@service)
    activate_menu :serviceadmin, :integration, :configuration
  end

  protected

  def find_service
    return super unless (service_system_name = params[:id].to_s.scan(/(.+)_backend_api/).flatten.first)
    @service = current_account.services.find_by(system_name: service_system_name)
  end
end
