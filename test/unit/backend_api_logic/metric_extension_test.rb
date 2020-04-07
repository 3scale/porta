# frozen_string_literal: true

require 'test_helper'

class MetricExtensionTest < ActiveSupport::TestCase
  setup do
    @backend_api = FactoryBot.create(:backend_api)
    @metric = FactoryBot.build(:metric, system_name: 'whatever', service_id: nil, owner: @backend_api)
  end

  attr_reader :backend_api, :metric

  test 'extends metric system_name with backend api id' do
    expected_system_name = "whatever.#{backend_api.id}"
    assert metric.save
    assert_equal expected_system_name, metric.reload.attributes['system_name']
    assert_equal expected_system_name, metric.system_name
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

  test 'extended system_name on update' do
    metric.system_name = "foo.#{backend_api.id}"
    assert metric.valid?

    metric.system_name = "foo.#{backend_api.id}0" # not the id of the backend api
    refute metric.valid?

    proxy_metric = FactoryBot.build(:metric, system_name: 'foo')
    assert proxy_metric.valid?

    proxy_metric.system_name = "foo.123"
    refute proxy_metric.valid?
  end

  class ClassMethodsTest < ActiveSupport::TestCase
    test '.build_extended_system_name' do
      assert_equal 'system_name.123', Metric.build_extended_system_name('system_name', owner_id: 123)
      assert_equal 'system_name.123', Metric.build_extended_system_name('system_name.123', owner_id: 123)
      assert_equal 'system_name.456.123', Metric.build_extended_system_name('system_name.456', owner_id: 123)
    end

    test '.system_name_without_suffix' do
      assert_equal 'system_name', Metric.system_name_without_suffix('system_name', owner_id: 123)
      assert_equal 'system_name', Metric.system_name_without_suffix('system_name.123', owner_id: 123)
    end
  end
end
