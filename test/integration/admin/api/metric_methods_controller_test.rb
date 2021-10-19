# frozen_string_literal: true

require 'test_helper'

class Admin::Api::MetricMethodsControllerTest < ActionDispatch::IntegrationTest

  def setup
    provider = FactoryBot.create(:provider_account)
    @service = FactoryBot.create(:service, account: provider)
    @metric  = @service.metrics.first
    @method_metric  = FactoryBot.create(:metric, service: @service, parent_id: @metric.id, friendly_name: 'my method')
    @access_token_value = FactoryBot.create(:access_token, owner: provider.admin_users.first!, scopes: %w[account_management], permission: 'rw').value

    host! provider.admin_domain
  end

  attr_reader :service, :metric, :method_metric, :access_token_value

  test 'index' do
    get admin_api_service_metric_methods_path(path_params)
    assert_response :success
  end

  test 'create' do
    post admin_api_service_metric_methods_path(path_params), params: { metric: { system_name: 'alaska', friendly_name: 'alaska' } }
    assert_response :success
  end

  test 'create record not unique' do
    Admin::Api::MetricMethodsController.any_instance.stubs(:create).raises(
      ActiveRecord::RecordNotUnique, 'Mysql2::Error: Duplicate entry')

    post admin_api_service_metric_methods_path(path_params), params: { metric: { system_name: 'alaska', friendly_name: 'alaska' } }
    assert_response :conflict
  end

  test 'update' do
    put admin_api_service_metric_method_path(path_params(id: method_metric.id)), params: { metric: { friendly_name: 'new friendly name' } }
    assert_response :success
    assert_equal 'new friendly name', method_metric.reload.friendly_name
  end

  test 'cannot update system_name' do
    old_system_name = method_metric.system_name
    put admin_api_service_metric_method_path(path_params(id: method_metric.id)), params: { metric: { system_name: 'new_system_name' } }
    assert_response :success
    assert_equal old_system_name, method_metric.reload.system_name
  end

  protected

  def path_params(extra_params = {})
    { service_id: service.id, metric_id: metric.id, access_token: access_token_value }.merge(extra_params)
  end
end
