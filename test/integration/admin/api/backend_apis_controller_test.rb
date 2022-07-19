# frozen_string_literal: true

require 'test_helper'

class Admin::Api::BackendApisControllerTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)
    host! provider.external_admin_domain
  end

  attr_reader :provider

  test 'show' do
    backend_api_configs = FactoryBot.create_list(:backend_api_config, 2, backend_api: backend_api)

    get admin_api_backend_api_path(backend_api), params: { access_token: access_token_value }

    assert_response :success
    backend_api_response = JSON.parse(response.body)
    assert_equal backend_api.id, backend_api_response.dig('backend_api', 'id')
  end

  test 'destroy' do
    delete admin_api_backend_api_path(backend_api), params: { access_token: access_token_value }
    assert_response :success
    assert backend_api.reload.deleted?
  end

  test 'destroy with errors' do
    provider.default_service.backend_api_configs.create!(backend_api: backend_api, path: 'whatever')

    delete admin_api_backend_api_path(backend_api), params: { access_token: access_token_value }
    refute backend_api.reload.deleted?
    assert_contains JSON.parse(response.body).dig('errors', 'base'), 'cannot be deleted because it is used by at least one Product'
  end

  test 'update' do
    put admin_api_backend_api_path(backend_api), params: { access_token: access_token_value, **permitted_params.merge(forbidden_params) }
    assert_response :success
    backend_api.reload
    assert_persists_right_params
  end

  test 'update with errors in the model' do
    put admin_api_backend_api_path(backend_api), params: { access_token: access_token_value, private_endpoint: '' }
    assert_response :unprocessable_entity
    assert_contains JSON.parse(response.body).dig('errors', 'private_endpoint'), 'can\'t be blank'
  end

  test 'create' do
    assert_difference(BackendApi.method(:count)) do
      post admin_api_backend_apis_path, params: { access_token: access_token_value, **permitted_params.merge(forbidden_params) }
      assert_response :created
    end
    assert(@backend_api = provider.backend_apis.find_by(id: JSON.parse(response.body).dig('backend_api', 'id')))
    assert_persists_right_params
  end

  test 'create with errors in the model' do
    post admin_api_backend_apis_path, params: { access_token: access_token_value,  private_endpoint: '' }
    assert_response :unprocessable_entity
    assert_contains JSON.parse(response.body).dig('errors', 'private_endpoint'), 'can\'t be blank'
  end

  test 'index' do
    FactoryBot.create_list(:backend_api, 2, account: provider)
    FactoryBot.create(:backend_api) # belonging to another provider
    get admin_api_backend_apis_path, params: { access_token: access_token_value }
    assert_response :success
    assert(response_collection_backend_apis = JSON.parse(response.body)['backend_apis'])
    assert_equal provider.backend_apis.count, response_collection_backend_apis.length
    response_collection_backend_apis.each do |response_backend_api|
      assert provider.backend_apis.find_by(id: response_backend_api.dig('backend_api', 'id'))
    end
  end

  test 'index can be paginated' do
    FactoryBot.create_list(:backend_api, 5, account: provider)
    provider.backend_apis.each_with_index { |backend_api, index| backend_api.update_column(:created_at, Date.today - index.days) }
    get admin_api_backend_apis_path, params: { access_token: access_token_value, per_page: 3, page: 2 }
    assert_response :success
    response_backend_api_ids = JSON.parse(response.body)['backend_apis'].map { |response_backend_api| response_backend_api.dig('backend_api', 'id') }
    assert_equal provider.backend_apis.oldest_first.offset(3).limit(3).select(:id).map(&:id), response_backend_api_ids
  end

  test 'system_name can be created but not updated' do
    post admin_api_backend_apis_path, params: permitted_params.merge(system_name: 'first-system-name', access_token: access_token_value)
    backend_api = provider.backend_apis.last!
    assert_equal 'first-system-name', backend_api.system_name

    put admin_api_backend_api_path(backend_api), params: permitted_params.merge(forbidden_params).merge(system_name: 'updated-system-name', access_token: access_token_value)
    assert_equal 'first-system-name', backend_api.reload.system_name
  end

  test 'backend api marked as deleted cannot be found' do
    backend_api.mark_as_deleted!

    get admin_api_backend_api_path(backend_api), params: { access_token: access_token_value }
    assert_response :not_found

    delete admin_api_backend_api_path(backend_api), params: { access_token: access_token_value }
    assert_response :not_found

    put admin_api_backend_api_path(backend_api), params: { access_token: access_token_value, **permitted_params }
    assert_response :not_found

    get admin_api_backend_apis_path, params: { access_token: access_token_value }
    assert_response :success
    response_backend_api_ids = JSON.parse(response.body)['backend_apis'].map { |response_backend_api| response_backend_api.dig('backend_api', 'id') }
    assert_not_includes response_backend_api_ids, backend_api.id
  end

  class MemberPermission < ActionDispatch::IntegrationTest
    def setup
      @provider = FactoryBot.create(:simple_provider)
      @backend_api = FactoryBot.create(:backend_api, account: provider)
      @member = FactoryBot.create(:member, account: provider)
      @access_token = FactoryBot.create(:access_token, owner: member, scopes: %w[account_management], permission: 'rw')
      member.activate!
      host! @provider.external_admin_domain
    end

    attr_reader :provider, :backend_api, :member, :access_token
    delegate :value, to: :access_token, prefix: true

    test 'member with permission' do
      member.admin_sections = %w[partners plans]
      member.save!

      get admin_api_backend_api_path(backend_api), params: { access_token: access_token_value }
      assert_response :success

      delete admin_api_backend_api_path(backend_api), params: { access_token: access_token_value }
      assert_response :forbidden

      put admin_api_backend_api_path(backend_api), params: { access_token: access_token_value, **backend_api_params }
      assert_response :success

      post admin_api_backend_apis_path, params: {access_token: access_token_value, **backend_api_params }
      assert_response :forbidden

      get admin_api_backend_apis_path, params: { access_token: access_token_value }
      assert_response :success
    end

    test 'member without permission' do
      get admin_api_backend_api_path(backend_api), params: { access_token: access_token_value }
      assert_response :forbidden

      delete admin_api_backend_api_path(backend_api), params: { access_token: access_token_value }
      assert_response :forbidden

      put admin_api_backend_api_path(backend_api), params: { access_token: access_token_value, **backend_api_params }
      assert_response :forbidden

      post admin_api_backend_apis_path, params: { access_token: access_token_value, **backend_api_params }
      assert_response :forbidden

      get admin_api_backend_apis_path, params: { access_token: access_token_value }
      assert_response :forbidden
    end

    protected

    def backend_api_params
      @backend_api_params ||= {
        name: 'the-name',
        description: 'New description.',
        private_endpoint: 'http://custom-api.example.org:80'
      }
    end
  end

  private

  def access_token_value
    @access_token_value ||= create_access_token_value(@provider.admin_users.first!)
  end

  def create_access_token_value(user)
    FactoryBot.create(:access_token, owner: user, scopes: %w[account_management], permission: 'rw').value
  end

  def backend_api
    @backend_api ||= FactoryBot.create(:backend_api, account: provider)
  end

  def assert_persists_right_params
    permitted_params.each do |attribute_name, value|
      assert_equal value, backend_api.public_send(attribute_name)
    end
    forbidden_params.each do |attribute_name, param_value|
      assert_not_equal param_value, backend_api.public_send(attribute_name)
    end
    assert backend_api.tenant_id
  end

  def permitted_params
    @permitted_params ||= {
      name: 'the-name',
      description: 'New description.',
      private_endpoint: 'http://custom-api.example.org:80'
    }
  end

  def forbidden_params
    @forbidden_params ||= {
      updated_at: 1.day.from_now,
      created_at: 1.day.from_now,
      account_id: @provider.id + 1
    }
  end
end
