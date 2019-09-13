# frozen_string_literal: true

require 'test_helper'

class MetricExtensionTest < ActiveSupport::TestCase
  setup do
    @backend_api = FactoryBot.create(:backend_api)
    @metric = FactoryBot.build(:metric, system_name: 'whatever', service_id: nil, owner: @backend_api)
  end

  attr_reader :backend_api, :metric

  test 'extends metric system_name with backend api id' do
    assert metric.save
    assert_equal "whatever.#{backend_api.id}", metric.reload.attributes['system_name']
  end

  test 'keeps showing system name without the suffix' do
    assert metric.save
    assert_equal "whatever", metric.system_name
  end

  test '#backend_api_metric?' do
    assert metric.backend_api_metric?
    service_metric = FactoryBot.create(:metric)
    refute service_metric.backend_api_metric?
  end

  test '#parent_id_for_service' do
    backend_hits = backend_api.metrics.hits
    backend_method = FactoryBot.build(:metric, system_name: 'bmeth', service_id: nil, owner: @backend_api, parent: backend_hits)
    backend_non_hits = metric

    service = FactoryBot.create(:service, account: backend_api.account)
    service_hits = service.metrics.hits
    service_method = FactoryBot.build(:metric, system_name: 'foo', owner: service, parent: service_hits)
    service_non_hits = FactoryBot.build(:metric, system_name: 'bar', owner: service)

    assert_equal service_hits.id, backend_hits.parent_id_for_service(service)
    assert_equal backend_hits.id, backend_method.parent_id_for_service(service)
    refute backend_non_hits.parent_id_for_service(service)

    refute service_hits.parent_id_for_service(service)
    assert_equal service_hits.id, service_method.parent_id_for_service(service)
    refute service_non_hits.parent_id_for_service(service)
  end
end
