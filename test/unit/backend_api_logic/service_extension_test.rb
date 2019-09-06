# frozen_string_literal: true

require 'test_helper'

class ServiceExtensionTest < ActiveSupport::TestCase
  test 'first_backend_api is nil when the service does not have any backend apis' do
    service = FactoryBot.build(:simple_service, account: nil)
    assert_nil service.first_backend_api
  end

  test 'first_backend_api should return the first created backend api for the service' do
    service = FactoryBot.build(:simple_service)
    service.backend_apis.build(name: 'first')
    service.backend_apis.build(name: 'second')
    assert_equal 'first', service.first_backend_api.name
  end

  test '#all_metrics' do
    service = FactoryBot.create(:simple_service, :with_default_backend_api)
    first_backend_api = service.first_backend_api
    second_backend_api = FactoryBot.create(:backend_api, account: service.account)
    third_backend_api = FactoryBot.create(:backend_api, account: service.account)
    service.backend_api_configs.create(backend_api: second_backend_api, path: 'whatever')

    related_metrics = [service.metrics.hits, first_backend_api.metrics.hits, second_backend_api.metrics.hits]
    related_metrics << FactoryBot.create(:metric, service: service)
    related_metrics << FactoryBot.create(:metric, service: nil, owner: first_backend_api)
    related_metrics << FactoryBot.create(:metric, service: nil, owner: second_backend_api)
    unrelated_metric = FactoryBot.create(:metric, service: nil, owner: third_backend_api)

    service_all_metrics = service.all_metrics

    assert_same_elements service_all_metrics, related_metrics
    assert_not_includes service_all_metrics, unrelated_metric
  end
end
