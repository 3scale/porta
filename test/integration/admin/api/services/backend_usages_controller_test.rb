# frozen_string_literal: true

require 'test_helper'

class Admin::Api::Services::BackendUsagesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @tenant = FactoryBot.create(:provider_account)
    @service = FactoryBot.create(:simple_service, account: @tenant)
    host! @tenant.internal_admin_domain
  end

  attr_reader :tenant, :service

  class WithAdminAccessToken < self
    def setup
      super
      @access_token = FactoryBot.create(:access_token, owner: @tenant.admin_users.first!, scopes: %w[account_management], permission: 'rw')
    end

    attr_reader :access_token
    delegate :value, to: :access_token, prefix: true

    test 'create' do
      assert_difference(service.backend_api_configs.method(:count)) do
        post admin_api_service_backend_usages_path(collection_params), params: { path: 'foo/bar', backend_api_id: backend_api.id }
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
        post admin_api_service_backend_usages_path(collection_params), params: { path: 'foo/bar', backend_api_id: backend_api_of_another_tenant.id }
        assert_response :not_found
      end
    end

    test 'destroy' do
      delete admin_api_service_backend_usage_path(resource_params)

      assert_response :success
      assert_raises(ActiveRecord::RecordNotFound) { backend_api_config.reload }
      assert backend_api.reload
      assert service.reload
    end

    test 'update' do
      another_backend_api = FactoryBot.create(:backend_api, account: tenant)

      put admin_api_service_backend_usage_path(resource_params), params: { path: 'foo/bar/updated', backend_api_id: another_backend_api.id }

      assert_response :success
      backend_api_config.reload
      assert_equal '/foo/bar/updated', backend_api_config.path
      assert_equal backend_api.id, backend_api_config.backend_api_id # because the path is the only param allowed in the update
    end

    test 'create or update with errors in the model' do
      assert_no_difference(service.backend_api_configs.method(:count)) do
        post admin_api_service_backend_usages_path(collection_params), params: { path: ':)', backend_api_id: backend_api.id }
        assert_response :unprocessable_entity
      end
      assert_match /must be a path separated by/, (JSON.parse(response.body).dig('errors', 'path') || []).join

      put admin_api_service_backend_usage_path(resource_params), params: { path: ':)' }
      assert_response :unprocessable_entity
      assert_match /must be a path separated by/, (JSON.parse(response.body).dig('errors', 'path') || []).join
    end

    test 'index can be paginated, skips unaccessible and the response has the right format' do
      FactoryBot.create_list(:backend_api_config, 5, service: service)

      get admin_api_service_backend_usages_path(collection_params(per_page: 3, page: 2))

      assert_response :success

      response_backend_api_configs = JSON.parse(response.body)
      expected_backend_api_configs = service.backend_api_configs.order(:id).offset(3).limit(3)
      assert_equal expected_backend_api_configs.size, response_backend_api_configs.length
      expected_backend_api_configs.each_with_index do |backend_api_config, index|
        response_item = response_backend_api_configs[index]['backend_usage'] || {}
        assert_equal backend_api_config.id, response_item['id']
        assert_equal backend_api_config.path, response_item['path']
        assert_equal backend_api_config.service.id, response_item['service_id']
        assert_equal backend_api_config.backend_api.id, response_item['backend_id']
        links = response_item.fetch('links', {})
        assert_equal 'service', links[0]['rel']
        assert_equal admin_api_service_url(backend_api_config.service), links[0]['href']
        assert_equal 'backend_api', links[1]['rel']
        assert_equal admin_api_backend_api_url(backend_api_config.backend_api), links[1]['href']
      end
    end

    test 'show' do
      get admin_api_service_backend_usage_path(resource_params)

      assert_response :success
      response_item = JSON.parse(response.body)['backend_usage'] || {}
      assert_equal backend_api_config.id, response_item['id']
      assert_equal service.id, response_item['service_id']
      assert_equal backend_api.id, response_item['backend_id']
      assert_equal backend_api_config.path, response_item['path']
      links = response_item.fetch('links', {})
      assert_equal 'service', links[0]['rel']
      assert_equal admin_api_service_url(backend_api_config.service), links[0]['href']
      assert_equal 'backend_api', links[1]['rel']
      assert_equal admin_api_backend_api_url(backend_api_config.backend_api), links[1]['href']
    end

    test 'show responds not found if the backend api config exists but but for another service' do
      another_service = FactoryBot.create(:simple_service, account: tenant)
      backend_api_config = FactoryBot.create(:backend_api_config, service: another_service)

      get admin_api_service_backend_usage_path(resource_params(id: backend_api_config.id))

      assert_response :not_found
    end

    test 'it cannot operate under a deleted service' do
      service.mark_as_deleted!
      backend_api_config = FactoryBot.create(:backend_api_config, service: service)

      get admin_api_service_backend_usages_path(collection_params(per_page: 3, page: 2))
      assert_response :not_found

      post admin_api_service_backend_usages_path(collection_params), params: { path: 'foo/bar', backend_api_id: backend_api.id }
      assert_response :not_found

      resource_params = resource_params(id: backend_api_config.id)

      put admin_api_service_backend_usage_path(resource_params), params: { path: 'foo/bar/updated' }
      assert_response :not_found

      delete admin_api_service_backend_usage_path(resource_params)
      assert_response :not_found
    end

    test 'it cannot create for a deleted backend_api' do
      backend_api.mark_as_deleted!

      post admin_api_service_backend_usages_path(collection_params), params: { path: 'foo/bar', backend_api_id: backend_api.id }
      assert_response :not_found
    end
  end

  class WithMemberAccessToken < self
    def setup
      super
      @member = FactoryBot.create(:member, account: tenant, admin_sections: %w[partners plans]) # FIXME: it should not require 'partners' permission
      @member.activate!

      @access_token = FactoryBot.create(:access_token, owner: member, scopes: %w[account_management], permission: 'rw')
    end

    attr_reader :member, :access_token
    delegate :value, to: :access_token, prefix: true

    test 'with permission to all services' do
      get admin_api_service_backend_usages_path(collection_params)
      assert_response :success

      post admin_api_service_backend_usages_path(collection_params), params: { path: 'foo', backend_api_id: backend_api.id }
      assert_response :success

      @backend_api_config = service.backend_api_configs.find(JSON.parse(response.body).dig('backend_usage', 'id'))

      get admin_api_service_backend_usage_path(resource_params)
      assert_response :success

      put admin_api_service_backend_usage_path(resource_params), params: { path: 'bar' }
      assert_response :success

      delete admin_api_service_backend_usage_path(resource_params)
      assert_response :success
    end

    test 'with permission to the service only' do
      member.member_permission_service_ids = [service.id]
      member.save!

      get admin_api_service_backend_usages_path(collection_params)
      assert_response :success

      post admin_api_service_backend_usages_path(collection_params), params: { path: 'foo', backend_api_id: backend_api.id }
      assert_response :success

      @backend_api_config = service.backend_api_configs.find(JSON.parse(response.body).dig('backend_usage', 'id'))

      get admin_api_service_backend_usage_path(resource_params)
      assert_response :success

      put admin_api_service_backend_usage_path(resource_params), params: { path: 'bar' }
      assert_response :success

      delete admin_api_service_backend_usage_path(resource_params)
      assert_response :success
    end

    test 'without permission' do
      other_service = FactoryBot.create(:simple_service, account: tenant)
      BackendApiConfig.create!(service: other_service, backend_api: backend_api, path: 'foo/bar') # other service uses the same backend api

      member.member_permission_service_ids = [other_service.id]
      member.save!

      get admin_api_service_backend_usage_path(resource_params)
      assert_response :not_found

      put admin_api_service_backend_usage_path(resource_params), params: { path: 'bar' }
      assert_response :not_found

      delete admin_api_service_backend_usage_path(resource_params)
      assert_response :not_found

      get admin_api_service_backend_usages_path(collection_params)
      assert_response :not_found

      post admin_api_service_backend_usages_path(collection_params), params: { path: 'foo', backend_api_id: FactoryBot.create(:backend_api, account: tenant).id }
      assert_response :not_found
    end
  end

  protected

  def backend_api_config
    @backend_api_config ||= BackendApiConfig.create!(service: service, backend_api: backend_api, path: 'foo/bar')
  end

  def backend_api
    @backend_api ||= FactoryBot.create(:backend_api, account: tenant)
  end

  def collection_params(other_params = {})
    { service_id: service.id, access_token: access_token_value }.merge(other_params)
  end

  def resource_params(other_params = {})
    collection_params(other_params).reverse_merge(id: backend_api_config.id)
  end
end
