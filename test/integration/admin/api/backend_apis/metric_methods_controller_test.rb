# frozen_string_literal: true

require 'test_helper'

class Admin::API::BackendApis::MetricMethodsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @tenant = FactoryBot.create(:provider_account)
    host! @tenant.admin_domain
    @access_token_value = FactoryBot.create(:access_token, owner: @tenant.admin_users.first!, scopes: %w[account_management], permission: 'rw').value
    @backend_api = FactoryBot.create(:backend_api, account: @tenant)
  end

  attr_reader :backend_api, :access_token_value, :tenant

  test 'index' do
    FactoryBot.create_list(:metric, 2, owner: backend_api, service_id: nil, parent: hits)

    FactoryBot.create(:metric, owner: FactoryBot.create(:backend_api, account: tenant), service_id: nil)
    FactoryBot.create(:metric, service: FactoryBot.create(:service, account: tenant))

    get admin_api_backend_api_metric_methods_path(backend_api_id: backend_api.id, metric_id: hits.id, access_token: access_token_value)

    assert_response :success
    assert(response_collection_methods_of_hits = JSON.parse(response.body)['methods'])
    assert_equal 2, response_collection_methods_of_hits.length
    response_collection_methods_of_hits.each do |response_method|
      assert hits.children.find_by(id: response_method.dig('method', 'id'))
    end
  end

  test 'show' do
    get admin_api_backend_api_metric_method_path(backend_api_id: backend_api.id, metric_id: hits.id, access_token: access_token_value, id: metric_method.id)

    assert_response :success
    assert_equal metric_method.id, JSON.parse(response.body).dig('method', 'id')
    assert_equal "#{metric_method.system_name}.#{backend_api.id}", metric_method.attributes['system_name']
  end

  test 'create' do
    assert_difference(Metric.method(:count)) do
      post admin_api_backend_api_metric_methods_path(backend_api_id: backend_api.id, metric_id: hits.id, access_token: access_token_value), { friendly_name: 'my friendly name', unit: 'hit' }
      assert_response :created
    end
    assert(@metric_method = hits.children.find_by(id: JSON.parse(response.body).dig('method', 'id')))
    assert_equal 'my friendly name', metric_method.friendly_name
    assert_equal 'hit', metric_method.unit
    assert_equal "my_friendly_name.#{backend_api.id}", metric_method.attributes['system_name']
  end

  test 'create with errors in the model' do
    post admin_api_backend_api_metric_methods_path(backend_api_id: backend_api.id, metric_id: hits.id, access_token: access_token_value), { friendly_name: '' }
    assert_response :unprocessable_entity
    assert_contains JSON.parse(response.body).dig('errors', 'friendly_name'), 'can\'t be blank'
  end

  test 'update' do
    put admin_api_backend_api_metric_method_path(backend_api_id: backend_api.id, metric_id: hits.id, access_token: access_token_value, id: metric_method.id), { friendly_name: 'my friendly name', unit: 'hit' }
    assert_response :success
    metric_method.reload
    assert_equal 'my friendly name', metric_method.friendly_name
    assert_equal 'hit', metric_method.unit
  end

  test 'update with errors in the model' do
    put admin_api_backend_api_metric_method_path(backend_api_id: backend_api.id, metric_id: hits.id, access_token: access_token_value, id: metric_method.id), { friendly_name: '' }
    assert_response :unprocessable_entity
    assert_contains JSON.parse(response.body).dig('errors', 'friendly_name'), 'can\'t be blank'
  end

  test 'destroy' do
    @metric_method = FactoryBot.create(:metric, owner: backend_api, service_id: nil, parent: hits)
    assert_difference(Metric.method(:count), -1) do
      delete admin_api_backend_api_metric_method_path(backend_api_id: backend_api.id, metric_id: hits.id, access_token: access_token_value, id: metric_method.id)
      assert_response :success
    end
    assert_raises(ActiveRecord::RecordNotFound) { metric_method.reload }
  end

  test 'without permission' do
    member = FactoryBot.create(:member, account: tenant)
    access_token_value = FactoryBot.create(:access_token, owner: member, scopes: %w[account_management], permission: 'rw').value

    get admin_api_backend_api_metric_method_path(backend_api_id: backend_api.id, metric_id: hits.id, access_token: access_token_value, id: metric_method.id)
    assert_response :forbidden

    delete admin_api_backend_api_metric_method_path(backend_api_id: backend_api.id, metric_id: hits.id, access_token: access_token_value, id: metric_method.id)
    assert_response :forbidden

    put admin_api_backend_api_metric_method_path(backend_api_id: backend_api.id, metric_id: hits.id, access_token: access_token_value, id: metric_method.id), { friendly_name: 'my friendly name', unit: 'hit' }
    assert_response :forbidden

    post admin_api_backend_api_metric_methods_path(backend_api_id: backend_api.id, metric_id: hits.id, access_token: access_token_value), { friendly_name: 'my friendly name', unit: 'hit' }
    assert_response :forbidden

    get admin_api_backend_api_metric_methods_path(backend_api_id: backend_api.id, metric_id: hits.id, access_token: access_token_value)
    assert_response :forbidden
  end

  test 'system_name can be created but not updated' do
    post admin_api_backend_api_metric_methods_path(backend_api_id: backend_api.id, metric_id: hits.id, access_token: access_token_value), { friendly_name: 'my friendly name', unit: 'hit', system_name: 'first-system-name' }
    metric_method = hits.children.last!
    assert_equal "first-system-name.#{backend_api.id}", metric_method.attributes['system_name']

    put admin_api_backend_api_metric_method_path(backend_api_id: backend_api.id, metric_id: hits.id, access_token: access_token_value, id: metric_method.id), { friendly_name: 'my friendly name', unit: 'hit', system_name: 'edited' }
    assert_equal "first-system-name.#{backend_api.id}", metric_method.reload.attributes['system_name']
  end

  test 'index can be paginated' do
    FactoryBot.create_list(:metric, 5, owner: backend_api, parent: hits, service_id: nil)

    get admin_api_backend_api_metric_methods_path(backend_api_id: backend_api.id, metric_id: hits.id, access_token: access_token_value, per_page: 3, page: 2)

    assert_response :success
    response_ids = JSON.parse(response.body)['methods'].map { |response| response.dig('method', 'id') }
    assert_equal hits.children.order(:id).offset(3).limit(3).select(:id).map(&:id), response_ids
  end

  private

  def metric_method
    @metric_method ||= FactoryBot.create(:metric, owner: backend_api, service_id: nil, parent: hits)
  end

  def hits
    @hits ||= backend_api.metrics.hits
  end

end
