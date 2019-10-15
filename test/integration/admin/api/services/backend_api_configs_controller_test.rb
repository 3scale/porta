# frozen_string_literal: true

require 'test_helper'

class Admin::API::Services::BackendApiConfigsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @tenant = FactoryBot.create(:provider_account)
    @service = FactoryBot.create(:simple_service, account: @tenant)
    host! @tenant.admin_domain
    @access_token_value = FactoryBot.create(:access_token, owner: @tenant.admin_users.first!, scopes: %w[account_management], permission: 'rw').value
  end

  attr_reader :tenant, :service, :access_token_value

  test 'create' do
    assert_difference(service.backend_api_configs.method(:count)) do
      post admin_api_service_backend_apis_path(service_id: service.id, access_token: access_token_value), {path: 'foo/bar', backend_api_id: backend_api.id}
      assert_response :created
    end
    backend_api_config = service.backend_api_configs.order(:id).last!
    assert_equal '/foo/bar', backend_api_config.path
    assert_equal service.id, backend_api_config.service_id
    assert_equal backend_api.id, backend_api_config.backend_api_id
  end

  test 'create for a backend_api of another tenant cannot find the backend api' do
    backend_api_of_another_tenant = FactoryBot.create(:backend_api)

    assert_no_difference(service.backend_api_configs.method(:count)) do
      post admin_api_service_backend_apis_path(service_id: service.id, access_token: access_token_value), {path: 'foo/bar', backend_api_id: backend_api_of_another_tenant.id}
      assert_response :not_found
    end
  end

  test 'destroy' do
    backend_api_config = BackendApiConfig.create!(service: service, backend_api: backend_api, path: 'foo/bar')

    delete admin_api_service_backend_api_path(service_id: service.id, id: backend_api.id, access_token: access_token_value)

    assert_response :success
    assert_raises(ActiveRecord::RecordNotFound) { backend_api_config.reload }
    assert backend_api.reload
    assert service.reload
  end

  test 'update' do
    backend_api_config = BackendApiConfig.create!(service: service, backend_api: backend_api, path: 'foo/bar')
    another_backend_api = FactoryBot.create(:backend_api, account: tenant)

    put admin_api_service_backend_api_path(service_id: service.id, id: backend_api.id, access_token: access_token_value), {path: 'foo/bar/updated', backend_api_id: another_backend_api.id}

    assert_response :success
    backend_api_config.reload
    assert_equal '/foo/bar/updated', backend_api_config.path
    assert_equal backend_api.id, backend_api_config.backend_api_id
  end

  test 'create or update with errors in the model' do
    BackendApiConfig.create!(service: service, backend_api: backend_api, path: 'foo/bar')

    assert_no_difference(service.backend_api_configs.method(:count)) do
      post admin_api_service_backend_apis_path(service_id: service.id, access_token: access_token_value), {path: 'foo/bar', backend_api_id: backend_api.id}
      assert_response :unprocessable_entity
    end
    assert_includes JSON.parse(response.body).dig('errors', 'backend_api_id'), 'has already been taken'

    put admin_api_service_backend_api_path(service_id: service.id, id: backend_api.id, access_token: access_token_value), {path: ':)'}
    assert_response :unprocessable_entity
    assert_match /must be a path separated by/, (JSON.parse(response.body).dig('errors', 'path') || []).join
  end

  test 'without permission' do
    member = FactoryBot.create(:member, account: tenant)
    access_token_value = FactoryBot.create(:access_token, owner: member, scopes: %w[account_management], permission: 'rw').value

    post admin_api_service_backend_apis_path(service_id: service.id, access_token: access_token_value), {path: 'foo/bar', backend_api_id: backend_api.id}
    assert_response :forbidden

    get admin_api_service_backend_apis_path(service_id: service.id, access_token: access_token_value)
    assert_response :forbidden

    delete admin_api_service_backend_api_path(service_id: service.id, id: backend_api.id, access_token: access_token_value)
    assert_response :forbidden

    put admin_api_service_backend_api_path(service_id: service.id, id: backend_api.id, access_token: access_token_value), {path: 'foo/bar/updated'}
    assert_response :forbidden

    get admin_api_service_backend_api_path(service_id: service.id, id: backend_api.id, access_token: access_token_value)
    assert_response :forbidden
  end

  test 'index can be paginated, skips unaccessible and the response has the right format' do
    FactoryBot.create_list(:backend_api_config, 5, service: service)

    get admin_api_service_backend_apis_path(service_id: service.id, access_token: access_token_value, per_page: 3, page: 2)

    assert_response :success

    response_backend_api_configs = JSON.parse(response.body)
    expected_backend_api_configs = service.backend_api_configs.order(:id).offset(3).limit(3)
    assert_equal expected_backend_api_configs.size, response_backend_api_configs.length
    expected_backend_api_configs.each_with_index do |backend_api_config, index|
      response_item = response_backend_api_configs[index]
      assert_equal backend_api_config.path, response_item['path']
      assert_equal backend_api_config.service.id, response_item['service_id']
      assert_equal backend_api_config.backend_api.id, response_item['id']
      links = response_item.fetch('links', {})
      assert_equal 'service', links[0]['rel']
      assert_equal admin_api_service_url(backend_api_config.service), links[0]['href']
      assert_equal 'backend_api', links[1]['rel']
      assert_equal admin_api_backend_api_url(backend_api_config.backend_api), links[1]['href']
    end
  end

  test 'show' do
    backend_api_config = BackendApiConfig.create!(service: service, backend_api: backend_api, path: 'foo/bar')

    get admin_api_service_backend_api_path(service_id: service.id, id: backend_api.id, access_token: access_token_value)

    assert_response :success
    response_item = JSON.parse(response.body)
    assert_equal service.id, response_item['service_id']
    assert_equal backend_api.id, response_item['id']
    assert_equal backend_api_config.path, response_item['path']
    links = response_item.fetch('links', {})
    assert_equal 'service', links[0]['rel']
    assert_equal admin_api_service_url(backend_api_config.service), links[0]['href']
    assert_equal 'backend_api', links[1]['rel']
    assert_equal admin_api_backend_api_url(backend_api_config.backend_api), links[1]['href']
  end

  test 'show responds not found if the backend api does not use that service' do
    get admin_api_service_backend_api_path(service_id: service.id, id: backend_api.id, access_token: access_token_value)

    assert_response :not_found
  end

  test 'it cannot operate under a deleted service' do
    service.mark_as_deleted!
    backend_api_config = FactoryBot.create(:backend_api_config, service: service)

    get admin_api_service_backend_apis_path(service_id: service.id, access_token: access_token_value, per_page: 3, page: 2)
    assert_response :not_found

    post admin_api_service_backend_apis_path(service_id: service.id, access_token: access_token_value), {path: 'foo/bar', backend_api_id: backend_api.id}
    assert_response :not_found

    put admin_api_service_backend_api_path(service_id: service.id, id: backend_api.id, access_token: access_token_value), {path: 'foo/bar/updated'}
    assert_response :not_found

    delete admin_api_service_backend_api_path(service_id: service.id, id: backend_api.id, access_token: access_token_value)
    assert_response :not_found
  end

  test 'it cannot create for a deleted backend_api' do
    backend_api.mark_as_deleted!

    post admin_api_service_backend_apis_path(service_id: service.id, access_token: access_token_value), {path: 'foo/bar', backend_api_id: backend_api.id}
    assert_response :not_found
  end

  private

  def backend_api
    @backend_api ||= FactoryBot.create(:backend_api, account: tenant)
  end
end
