# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::BackendApis::MetricsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = FactoryBot.create(:provider_account)
    @service = @provider.first_service
    @backend_api = @service.backend_api

    @hits = @provider.metrics.hits
    @meth = FactoryBot.create(:metric, service: @service, system_name: 'meth', parent: @hits)
    @ads = FactoryBot.create(:metric, service: @service, system_name: 'ads')

    login_provider @provider
  end

  attr_reader :provider, :service, :backend_api, :hits, :meth, :ads

  test '#index' do
    get provider_admin_backend_api_metrics_path(backend_api)
    assert_response :success

    assert_select 'table#methods.data tr', count: 2 # 1 of the method + header
    assert_select 'table#methods.data tr td', text: meth.system_name

    assert_select 'table#metrics.data tr', count: 3 # 2 of the metrics + header
    [hits, ads].each { |metric| assert_select 'table#metrics.data tr td', text: metric.system_name }
  end

  test '#new' do
    get new_provider_admin_backend_api_metric_child_path(backend_api, hits)
    assert_response :success
    action = admin_service_metric_children_path(service, hits) # FIXME: It should be provider_admin_backend_api_metric_children_path(backend_api, hits)
    assert_select "form.metric[action='#{action}']"

    get new_provider_admin_backend_api_metric_path(backend_api)
    assert_response :success
    action = admin_service_metrics_path(service) # FIXME: It should be provider_admin_backend_api_metrics_path(backend_api)
    assert_select "form.metric[action='#{action}']"
  end

  test '#edit' do
    get edit_provider_admin_backend_api_metric_path(backend_api, ads)
    assert_response :success
    action = admin_service_metric_path(service, ads) # FIXME: It should be provider_admin_backend_api_metric_path(backend_api, ads)
    assert_select "form.metric[action='#{action}']"
  end
end
