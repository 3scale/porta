# frozen_string_literal: true

require 'test_helper'

class Api::MetricsControllerTest < ActionDispatch::IntegrationTest
  def setup
    provider  = FactoryBot.create(:provider_account)
    @service   = FactoryBot.create(:service, account: provider)
    @metric   = FactoryBot.create(:metric, service: @service, friendly_name: 'super metric')

    login! provider
  end

  test 'index' do
    get admin_service_metrics_path(service_id: @service.id)
    assert_response :success
    assert_select 'title', "Metrics - Index | Red Hat 3scale API Management"
    assert_select '#metrics a', 'Hits'
  end

  test 'new metric' do
    get new_admin_service_metric_path(service_id: @service.id)
    assert_response :success
    assert_select 'title', "Metrics - New | Red Hat 3scale API Management"
  end

  test 'new method' do
    get new_admin_service_metric_child_path(service_id: @service.id, metric_id: @service.metrics.hits)
    assert_response :success
    assert_select 'title', "Metrics - New | Red Hat 3scale API Management"
  end

  test 'create metric' do
    assert_difference @service.metrics.method(:count) do
      post admin_service_metrics_path(service_id: @service.id), params: { metric: { system_name: 'upgrades', friendly_name: 'upgrades', unit: 'upgrades' } }
      assert_response :redirect
    end
  end

  test 'create method' do
    assert_difference @service.metrics.method(:count) do
      post admin_service_metrics_path(service_id: @service.id, metric_id: @service.metrics.hits), params: { metric: { system_name: 'alaska', friendly_name: 'alaska' } }
      assert_response :redirect
    end
  end

  test 'edit' do
    get edit_admin_service_metric_path(service_id: @service.id, id: @metric.id)
    assert_response :success
    assert_select 'title', "Metrics - Edit | Red Hat 3scale API Management"
  end

  test 'update' do
    patch admin_service_metric_path(service_id: @service.id, id: @metric.id), params: { metric: { friendly_name: 'new friendly name' } }
    assert_response :redirect
    assert_equal 'new friendly name', @metric.reload.friendly_name
  end

  test 'cannot update system_name' do
    assert_equal 'super_metric', @metric.system_name
    patch admin_service_metric_path(service_id: @service.id, id: @metric.id), params: { metric: { system_name: 'new_system_name' } }
    assert_response :redirect
    assert_equal 'super_metric', @metric.reload.system_name
  end

  test 'destroy' do
    assert_difference @service.metrics.method(:count), -1 do
      delete admin_service_metric_path(service_id: @service.id, id: @metric.id)
      assert_response :redirect
      assert_equal 'The metric was deleted', flash[:notice]
    end
  end

  test 'cannot destroy hits' do
    assert_no_difference @service.metrics.method(:count) do
      delete admin_service_metric_path(service_id: @service.id, id: @service.metrics.hits)
      assert_response :redirect
      assert_equal 'The Hits metric cannot be deleted', flash[:error]
    end
  end
end
