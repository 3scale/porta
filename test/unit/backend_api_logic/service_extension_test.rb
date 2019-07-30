# frozen_string_literal: true

require 'test_helper'

class ServiceExtensionTest < ActiveSupport::TestCase
  test 'first_backend_api is nil when the service does not have an account' do
    service = FactoryBot.build(:simple_service, account: nil)
    assert_nil service.first_backend_api
  end

  test 'first_backend_api when the service is not persisted but has an account' do
    service = FactoryBot.build(:simple_service)
    assert(backend_api = service.first_backend_api)
    assert_equal service.account_id, backend_api.account_id
    refute backend_api.persisted?
  end

  test 'first_backend_api default values' do
    service = FactoryBot.build(:simple_service, system_name: nil)
    assert(backend_api = service.first_backend_api)
    assert_equal "#{service.name} Backend API", backend_api.name
    assert_equal  "Backend API of #{service.name}", backend_api.description
  end

  test 'first_backend_api when the service its own system_name' do
    service = FactoryBot.build(:simple_service, system_name: 'example-system-name')
    assert_equal service.system_name, service.first_backend_api.system_name
  end

  test 'first_backend_api when the service is persisted' do
    service = FactoryBot.create(:simple_service)
    assert(backend_api = service.first_backend_api)
    assert backend_api.persisted?
    assert_equal service.account_id, backend_api.account_id
    assert backend_api.id, service.reload.first_backend_api.id # It finds it bcz it was previously created instead of creating a new one
    assert_not_nil backend_api.system_name # it is generated although service.system_name is nil
    assert_equal BackendApi.default_api_backend, backend_api.private_endpoint # because service does not have a proxy so it takes the default api_backend
  end

  test 'first_backend_api when the service has a proxy with its api_backend' do
    proxy = FactoryBot.create(:proxy)
    backend_api = proxy.service.first_backend_api
    assert_equal proxy.api_backend, backend_api.private_endpoint
    assert_not_equal BackendApi.default_api_backend, backend_api.private_endpoint
  end
end
