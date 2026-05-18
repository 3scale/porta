# frozen_string_literal: true

require 'test_helper'

class ServiceExtensionTest < ActiveSupport::TestCase
  test '#all_metrics' do
    service = FactoryBot.create(:simple_service, :with_default_backend_api)
    first_backend_api = service.backend_api
    second_backend_api = FactoryBot.create(:backend_api, account: service.account)
    third_backend_api = FactoryBot.create(:backend_api, account: service.account)
    service.backend_api_configs.create(backend_api: second_backend_api, path: 'whatever')

    related_metrics = [service.metrics.hits, first_backend_api.metrics.hits, second_backend_api.metrics.hits]
    related_metrics << FactoryBot.create(:metric, service: service, owner: nil)
    related_metrics << FactoryBot.create(:metric, owner: service)
    related_metrics << FactoryBot.create(:metric, service: nil, owner: first_backend_api)
    related_metrics << FactoryBot.create(:metric, service: nil, owner: second_backend_api)
    unrelated_metric = FactoryBot.create(:metric, service: nil, owner: third_backend_api)

    service_all_metrics = service.all_metrics

    assert_same_elements service_all_metrics, related_metrics
    assert_not_includes service_all_metrics, unrelated_metric
  end

  class BackendApiProxy < ActiveSupport::TestCase
    test '#backend_api_config builds a new backend api config if does not exist' do
      service = FactoryBot.create(:simple_service)

      refute service.backend_api_proxy.backend_api_config.persisted?
    end

    test '#backend_api_config returns the already existent backend api config for the service' do
      service = FactoryBot.create(:simple_service)
      backend_api_config = FactoryBot.create(:backend_api_config, service: service)

      assert_equal backend_api_config, service.backend_api_proxy.backend_api_config
    end

    test '#backend_api returns backend_api from the first backend_api_configs, if persisted' do
      service = FactoryBot.create(:simple_service)
      backend_api = FactoryBot.create(:backend_api, account: service.account)
      another_backend_api = FactoryBot.create(:backend_api, account: service.account)
      FactoryBot.create(:backend_api_config, service: service, backend_api: backend_api, path: '/one')
      FactoryBot.create(:backend_api_config, service: service, backend_api: another_backend_api, path: '/two')

      assert_equal 2, service.reload.backend_api_configs.count

      first_result = service.backend_api
      assert_equal backend_api, first_result

      # The second call returns the memoized instance
      second_result = service.backend_api
      assert_same first_result, second_result
    end

    test '#update! saves backend_api_config and backend_api for the service' do
      service = FactoryBot.create(:simple_service)

      # built on demand
      backend_api = service.backend_api
      assert_not backend_api.persisted?
      assert_not service.backend_api_proxy.backend_api_config.persisted?

      service.backend_api_proxy.update!(private_endpoint: 'https://api.example.com', path: '/backend-path')

      # memoized instances, but now persisted
      persisted_backend_api = service.backend_api

      assert persisted_backend_api.persisted?
      assert service.backend_api_proxy.backend_api_config.persisted?

      assert_same backend_api, persisted_backend_api
    end

    test '#backend_api builds and memoizes unpersisted backend_api' do
      service = FactoryBot.create(:simple_service)
      proxy = service.backend_api_proxy

      # First call builds unpersisted backend_api
      first_call = proxy.backend_api
      assert_not first_call.persisted?
      assert_equal service.account, first_call.account
      assert_equal service.system_name, first_call.system_name

      # Second call returns the same memoized unpersisted instance
      second_call = proxy.backend_api
      assert_same first_call, second_call
      assert_not second_call.persisted?
    end

    test '#backend_api_config memoizes across multiple calls' do
      service = FactoryBot.create(:simple_service)
      proxy = service.backend_api_proxy

      first_call = proxy.backend_api_config
      second_call = proxy.backend_api_config

      assert_not first_call.persisted?
      assert_not second_call.persisted?
      assert_same first_call, second_call
    end

    test '#backend_api does not pollute account.backend_apis association with unpersisted records' do
      service = FactoryBot.create(:simple_service)
      account = service.account

      initial_count = account.backend_apis.count

      # Call backend_api which builds an unpersisted backend_api
      backend_api = service.backend_api_proxy.backend_api
      assert_not backend_api.persisted?

      # Association should not include unpersisted record
      assert_equal initial_count, account.backend_apis.count
      assert_not_includes account.backend_apis, backend_api
    end
  end
end
