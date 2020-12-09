require 'test_helper'

class ServiceCreatorTest < ActiveSupport::TestCase
  test 'service creation without path and endpoint' do
    service = FactoryBot.build(:service)
    creator = ServiceCreator.new(service: service)
    creator.call
    assert service.persisted?
    assert service.backend_api_proxy.backend_api.new_record?
  end

  test 'service creation with path and private_endpoint' do
    service = FactoryBot.build(:service)
    creator = ServiceCreator.new(service: service)
    creator.call(path: 'new', private_endpoint: 'http://new.example.com')

    assert service.persisted?
    backend_api = service.backend_api_proxy.backend_api
    backend_api_config = service.backend_api_proxy.backend_api_config
    assert backend_api.persisted?
    assert backend_api_config.persisted?
    assert_equal '/new', backend_api_config.path
    assert_equal 'http://new.example.com:80', backend_api.private_endpoint
  end

  test 'service creation with invalid private_endpoint' do
    service = FactoryBot.build(:service)
    creator = ServiceCreator.new(service: service)
    creator.call(path: 'foo')

    refute service.persisted?
    backend_api = service.backend_api_proxy.backend_api
    backend_api_config = service.backend_api_proxy.backend_api_config
    refute backend_api.persisted?
    refute backend_api_config.persisted?
  end

  test 'service with assigned backend api' do
    backend_api = FactoryBot.create(:backend_api)
    account = backend_api.account
    service = FactoryBot.build(:service, account: account)
    creator = ServiceCreator.new(service: service, backend_api: backend_api)
    creator.call
    backend_api = service.backend_api_proxy.backend_api
    backend_api_config = service.backend_api_proxy.backend_api_config
    assert service.persisted?
    assert backend_api.persisted?
    assert backend_api_config.persisted?
  end

  test 'service with a long system_name used in its proxy endpoint' do
    system_name = 'this-hostname-label-is-longer-than-63-chars-which-is-not-allowed-according-to-rfc-1035'
    service = FactoryBot.build(:service, system_name: system_name)
    ServiceCreator.new(service: service).call
    assert_match /this-hostname-label-is-longer-than-63-chars-which-is-no-/, service.proxy.endpoint
  end
end
