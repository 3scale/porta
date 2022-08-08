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
  end
end
