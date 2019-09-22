# frozen_string_literal: true

require 'test_helper'

class Admin::API::BackendApis::ServicesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @tenant = FactoryBot.create(:provider_account)
    host! @tenant.admin_domain
    @access_token_value = FactoryBot.create(:access_token, owner: @tenant.admin_users.first!, scopes: %w[account_management], permission: 'rw').value
    @backend_api = FactoryBot.create(:backend_api, account: @tenant)
  end

  attr_reader :backend_api, :access_token_value, :tenant

  test 'index' do
    FactoryBot.create(:service, account: tenant)
    tenant.services.each { |service| FactoryBot.create(:backend_api_config, backend_api: backend_api, service: service) }
    expected_service_ids = tenant.services.pluck(:id)

    deleted_service = FactoryBot.create(:service, account: tenant, state: :deleted)
    FactoryBot.create(:backend_api_config, backend_api: backend_api, service: deleted_service)

    service_without_backend_api = FactoryBot.create(:service, account: tenant)

    service_with_another_backend_api = FactoryBot.create(:service, account: tenant)
    another_backend_api = FactoryBot.create(:backend_api, account: tenant)
    FactoryBot.create(:backend_api_config, backend_api: another_backend_api, service: service_with_another_backend_api)

    get admin_api_backend_api_services_path(backend_api_id: backend_api.id, access_token: access_token_value)

    assert_response :success
    assert(response_collection = JSON.parse(response.body)['services'])
    service_ids = response_collection.map { |response_service| response_service.dig('service', 'id') }

    assert_equal expected_service_ids, service_ids
  end

  test 'create' do
    assert_difference(backend_api.services.method(:count)) do
      post admin_api_backend_api_services_path(backend_api_id: backend_api.id, access_token: access_token_value), service_params
      assert_response :created
    end
    @service = backend_api.services.order(:id).last!
    assert_equal service.id, JSON.parse(response.body).dig('service', 'id')
  end

  test 'create with errors in the model' do
    assert_no_difference(backend_api.services.method(:count)) do
      post admin_api_backend_api_services_path(backend_api_id: backend_api.id, access_token: access_token_value), service_params.merge({backend_version: 'fake'})
      assert_response :unprocessable_entity
    end
    assert_contains JSON.parse(response.body).dig('errors', 'backend_version'), 'is not included in the list'
  end

  test 'show' do
    get admin_api_backend_api_service_path(backend_api_id: backend_api.id, access_token: access_token_value, id: service.id)
    assert_response :success
    assert_equal service.id, JSON.parse(response.body).dig('service', 'id')
  end

  test 'update' do
    put admin_api_backend_api_service_path(backend_api_id: backend_api.id, access_token: access_token_value, id: service.id), {name: 'new name'}
    assert_response :success
    assert_equal 'new name', service.reload.name
  end

  test 'update with errors in the model' do
    old_backend_version = service.backend_version
    put admin_api_backend_api_service_path(backend_api_id: backend_api.id, access_token: access_token_value, id: service.id), {backend_version: 'fake'}
    assert_response :unprocessable_entity
    assert_contains JSON.parse(response.body).dig('errors', 'backend_version'), 'is not included in the list'
    assert_equal old_backend_version, service.reload.backend_version
  end

  test 'destroy' do
    assert_change(of: -> { service.reload.deleted? }, from: false, to: true) do
      delete admin_api_backend_api_service_path(backend_api_id: backend_api.id, access_token: access_token_value, id: service.id)
      assert_response :ok
    end
  end

  private

  def service
    @service ||= begin
      service = FactoryBot.create(:service, account: tenant)
      FactoryBot.create(:backend_api_config, backend_api: backend_api, service: service)
      service
    end
  end

  def service_params
    @service_params = {name: 'the name', description: 'hello'}
  end
end
