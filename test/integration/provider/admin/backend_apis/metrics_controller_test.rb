# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::BackendApis::MetricsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = FactoryBot.create(:provider_account)
    @service = @provider.first_service
    @backend_api = @service.backend_api

    @hits = @backend_api.metrics.hits
    @meth = FactoryBot.create(:metric, service: nil, owner: @backend_api, system_name: 'meth', parent: @hits)
    @ads = FactoryBot.create(:metric, service: nil, owner: @backend_api, system_name: 'ads')

    login_provider @provider
  end

  attr_reader :provider, :service, :backend_api, :hits, :meth, :ads

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
      post provider_admin_backend_api_metrics_path(backend_api), params: { metric: metric_params }
      assert_response :redirect
      assert backend_api.metrics.find_by(system_name: "foo.#{backend_api.id}")
    end

    assert_no_difference backend_api.metrics.method(:count) do
      post provider_admin_backend_api_metrics_path(backend_api), params: { metric: metric_params }
      assert_equal 'Metric could not be created', flash[:error]
    end
  end

  test '#create method' do
    metric_params = { friendly_name: 'Foo', system_name: 'foo', unit: 'foo', description: 'Just a foo metric', metric_id: hits.id }

    assert_difference backend_api.metrics.method(:count) do
      post provider_admin_backend_api_metric_children_path(backend_api, hits), params: { metric: metric_params }
      assert_response :redirect
      assert backend_api.metrics.find_by(system_name: "foo.#{backend_api.id}")
    end

    assert_no_difference backend_api.metrics.method(:count) do
      post provider_admin_backend_api_metric_children_path(backend_api, hits), params: { metric: metric_params }
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
    put provider_admin_backend_api_metric_path(backend_api, ads), params: { metric: { description: new_description } }
    assert_response :redirect
    assert_equal new_description, ads.reload.description

    put provider_admin_backend_api_metric_path(backend_api, ads), params: { metric: { friendly_name: '' } }
    assert_equal 'Metric could not be updated', flash[:error]
    assert_select '#metric_friendly_name_input.required.error'
  end

  test 'cannot update system_name' do
    put provider_admin_backend_api_metric_path(backend_api, ads), params: { metric: { system_name: 'new_system_name' } }
    assert_response :redirect
    assert_equal "ads.#{backend_api.id}", ads.reload.system_name
  end

  test '#destroy' do
    delete provider_admin_backend_api_metric_path(backend_api, ads)
    assert_not backend_api.metrics.find_by(system_name: "ads.#{backend_api.id}")
  end

  test 'it cannot operate for metrics under a non-accessible backend api' do
    backend_api = FactoryBot.create(:backend_api, account: @provider, state: :deleted)
    hits = backend_api.metrics.hits
    metric_method = FactoryBot.create(:metric, owner: backend_api, service_id: nil, parent: hits)

    get provider_admin_backend_api_metrics_path(backend_api)
    assert_response :not_found

    get new_provider_admin_backend_api_metric_child_path(backend_api, hits)
    assert_response :not_found

    delete provider_admin_backend_api_metric_path(backend_api, ads)
    assert_response :not_found

    put provider_admin_backend_api_metric_path(backend_api, ads), params: { metric: { friendly_name: '' } }
    assert_response :not_found

    get edit_provider_admin_backend_api_metric_path(backend_api, ads)
    assert_response :not_found

    post provider_admin_backend_api_metrics_path(backend_api), params: { metric: { friendly_name: 'Foo', unit: 'foo' } }
    assert_response :not_found

    post provider_admin_backend_api_metric_children_path(backend_api, hits), params: { metric: { friendly_name: 'Foo', unit: 'foo', metric_id: hits.id } }
    assert_response :not_found
  end

  test 'member permissions' do
    member = FactoryBot.create(:member, account: provider)
    member.activate!

    logout! && login!(provider, user: member)

    get provider_admin_backend_api_metrics_path(backend_api)
    assert_response :forbidden

    get new_provider_admin_backend_api_metric_child_path(backend_api, hits)
    assert_response :forbidden

    get edit_provider_admin_backend_api_metric_path(backend_api, ads)
    assert_response :forbidden

    put provider_admin_backend_api_metric_path(backend_api, ads), params: { metric: { friendly_name: '' } }
    assert_response :forbidden

    delete provider_admin_backend_api_metric_path(backend_api, ads)
    assert_response :forbidden

    post provider_admin_backend_api_metrics_path(backend_api), params: { metric: { friendly_name: 'Foo', unit: 'foo' } }
    assert_response :forbidden

    post provider_admin_backend_api_metric_children_path(backend_api, hits), params: { metric: { friendly_name: 'Foo', unit: 'foo', metric_id: hits.id } }
    assert_response :forbidden

    member.admin_sections = %w[plans]
    member.save!

    get provider_admin_backend_api_metrics_path(backend_api)
    assert_response :success

    get new_provider_admin_backend_api_metric_child_path(backend_api, hits)
    assert_response :success

    get edit_provider_admin_backend_api_metric_path(backend_api, ads)
    assert_response :success

    put provider_admin_backend_api_metric_path(backend_api, ads), params: { metric: { friendly_name: '' } }
    assert_response :success

    delete provider_admin_backend_api_metric_path(backend_api, ads)
    assert_response :redirect

    post provider_admin_backend_api_metrics_path(backend_api), params: { metric: { friendly_name: 'Foo', unit: 'foo' } }
    assert_response :redirect

    post provider_admin_backend_api_metric_children_path(backend_api, hits), params: { metric: { friendly_name: 'Foo', unit: 'foo', metric_id: hits.id } }
    assert_response :success
  end
end
