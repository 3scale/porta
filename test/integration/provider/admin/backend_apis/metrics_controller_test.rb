# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::BackendApis::MetricsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = FactoryBot.create(:provider_account)
    @service = @provider.first_service
    @service.build_default_backend_api_config.save!
    @backend_api = @service.backend_api

    @hits = @backend_api.metrics.hits
    @meth = FactoryBot.create(:metric, service: nil, owner: @backend_api, system_name: 'meth', parent: @hits)
    @ads = FactoryBot.create(:metric, service: nil, owner: @backend_api, system_name: 'ads')

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
    action = provider_admin_backend_api_metric_children_path(backend_api, hits)
    assert_select "form.metric[action='#{action}']"

    get new_provider_admin_backend_api_metric_path(backend_api)
    assert_response :success
    action = provider_admin_backend_api_metrics_path(backend_api)
    assert_select "form.metric[action='#{action}']"
  end

  test '#create metric' do
    metric_params = { friendly_name: 'Foo', system_name: 'foo', unit: 'foo', description: 'Just a foo metric' }

    assert_difference backend_api.metrics.method(:count) do
      post provider_admin_backend_api_metrics_path(backend_api, metric: metric_params)
      assert_response :redirect
      assert backend_api.metrics.find_by(system_name: "foo.#{backend_api.id}")
    end

    assert_no_difference backend_api.metrics.method(:count) do
      post provider_admin_backend_api_metrics_path(backend_api, metric: metric_params)
      assert_equal 'Metric could not be created', flash[:error]
    end
  end

  test '#create method' do
    metric_params = { friendly_name: 'Foo', system_name: 'foo', unit: 'foo', description: 'Just a foo metric', metric_id: hits.id }

    assert_difference backend_api.metrics.method(:count) do
      post provider_admin_backend_api_metric_children_path(backend_api, hits, metric: metric_params)
      assert_response :redirect
      assert backend_api.metrics.find_by(system_name: "foo.#{backend_api.id}")
    end

    assert_no_difference backend_api.metrics.method(:count) do
      post provider_admin_backend_api_metric_children_path(backend_api, hits, metric: metric_params)
      assert_equal 'Method could not be created', flash[:error]
    end
  end

  test '#edit' do
    get edit_provider_admin_backend_api_metric_path(backend_api, ads)
    assert_response :success
    action = provider_admin_backend_api_metric_path(backend_api, ads)
    assert_select "form.metric[action='#{action}']"
  end

  test '#update' do
    new_description = "New description #{rand}"
    put provider_admin_backend_api_metric_path(backend_api, ads, metric: { description: new_description })
    assert_response :redirect
    assert_equal new_description, ads.reload.description

    put provider_admin_backend_api_metric_path(backend_api, ads, metric: { friendly_name: '' })
    assert_equal 'Metric could not be updated', flash[:error]
    assert_select '#metric_friendly_name_input.required.error'
  end

  test '#destroy' do
    delete provider_admin_backend_api_metric_path(backend_api, ads)
    refute backend_api.metrics.find_by(system_name: "ads.#{backend_api.id}")
  end
end
