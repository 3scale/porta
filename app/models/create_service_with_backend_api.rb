# frozen_string_literal: true

# This class handles the creation of a Service with a Backend API attached to it if informed. It can attach an already
# existent Backend API or build a new one. It will only attach/create the Backend API if the Account is in
# the api_as_product Rolling Update.
#
# Examples
#
#   CreateServiceWithBackendApi.new(service: service, account: account, backend_api: 'new')
#   # => true # This will create a default backend api and attach it to the service.
#
#   CreateServiceWithBackendApi.new(service: service, account: account, backend_api: 1)
#   # => true # This will only attach the service with id 1 to the service.
class CreateServiceWithBackendApi
  def initialize(service:, account:, backend_api:)
    @account     = account
    @backend_api = backend_api
    @service     = service
  end

  def call
    build_backend_api if @account.provider_can_use?(:api_as_product)
    @service.save
  end

  private

  def build_backend_api
    return unless @backend_api

    if @backend_api == 'new'
      @service.build_default_backend_api_config
    else
      backend_api = @account.backend_apis.find(@backend_api)
      @service.backend_api_configs = [BackendApiConfig.new(backend_api: backend_api)]
    end
  end
end