# frozen_string_literal: true

require 'test_helper'

class Admin::API::AccountsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)
    host! @provider.admin_domain
    @access_token_value = FactoryBot.create(:access_token, owner: @provider.admin_users.first!, scopes: %w[account_management], permission: 'rw').value
    Logic::RollingUpdates.stubs(enabled?: true)
    Logic::RollingUpdates::Features::ApiAsProduct.any_instance.stubs(:enabled?).returns(true)
    @backend_api = FactoryBot.create(:backend_api, account: provider)
  end

  attr_reader :provider, :access_token_value, :backend_api

  test 'show' do
    get admin_api_backend_api_path(backend_api, access_token: access_token_value)
    assert_response :success
    assert_equal backend_api.id, JSON.parse(response.body).dig('backend_api', 'id')
  end

  test 'destroy' do
    assert_difference(BackendApi.method(:count), -1) do
      delete admin_api_backend_api_path(backend_api, access_token: access_token_value)
      assert_response :success
    end
    assert_raises(ActiveRecord::RecordNotFound) { backend_api.reload }
  end

  test 'update' do
    put admin_api_backend_api_path(backend_api, access_token: access_token_value), permitted_params.merge(forbidden_params)
    assert_response :success
    backend_api.reload
    assert_persists_right_params
  end

  test 'update with errors in the model' do
    put admin_api_backend_api_path(backend_api, access_token: access_token_value), { private_endpoint: '' }
    assert_response :unprocessable_entity
    assert_contains JSON.parse(response.body).dig('errors', 'private_endpoint'), 'can\'t be blank'
  end

  test 'create' do
    assert_difference(BackendApi.method(:count)) do
      post admin_api_backend_apis_path(access_token: access_token_value), permitted_params.merge(forbidden_params)
      assert_response :created
    end
    assert(@backend_api = provider.backend_apis.find_by(id: JSON.parse(response.body).dig('backend_api', 'id')))
    assert_persists_right_params
  end

  test 'create with errors in the model' do
    post admin_api_backend_apis_path(access_token: access_token_value), { private_endpoint: '' }
    assert_response :unprocessable_entity
    assert_contains JSON.parse(response.body).dig('errors', 'private_endpoint'), 'can\'t be blank'
  end

  test 'index' do
    FactoryBot.create(:backend_api, account: provider) # another backend_api of this provider
    FactoryBot.create(:backend_api) # belonging to another provider
    get admin_api_backend_apis_path(access_token: access_token_value)
    assert_response :success
    assert(response_collection_backend_apis = JSON.parse(response.body)['backend_apis'])
    assert_equal provider.backend_apis.count, response_collection_backend_apis.length
    response_collection_backend_apis.each do |response_backend_api|
      assert provider.backend_apis.find_by(id: response_backend_api.dig('backend_api', 'id'))
    end
  end

  test 'index can be paginated' do
    FactoryBot.create_list(:backend_api, 5, account: provider)
    get admin_api_backend_apis_path(access_token: access_token_value, per_page: 3, page: 2)
    assert_response :success
    response_backend_api_ids = JSON.parse(response.body)['backend_apis'].map { |response_backend_api| response_backend_api.dig('backend_api', 'id') }
    assert_same_elements provider.backend_apis.offset(3).limit(3).pluck(:id), response_backend_api_ids
  end

  test 'with the rolling update disabled' do
    Logic::RollingUpdates::Features::ApiAsProduct.any_instance.stubs(:enabled?).returns(false)

    get admin_api_backend_api_path(backend_api, access_token: access_token_value)
    assert_response :not_found

    delete admin_api_backend_api_path(backend_api, access_token: access_token_value)
    assert_response :not_found

    put admin_api_backend_api_path(backend_api, access_token: access_token_value), permitted_params
    assert_response :not_found

    post admin_api_backend_apis_path(access_token: access_token_value), permitted_params
    assert_response :not_found

    get admin_api_backend_apis_path(access_token: access_token_value)
    assert_response :not_found
  end

  private

  def assert_persists_right_params
    permitted_params.each do |attribute_name, value|
      assert_equal value, backend_api.public_send(attribute_name)
    end
    forbidden_params.each do |attribute_name, param_value|
      assert_not_equal param_value, backend_api.public_send(attribute_name)
    end
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
      system_name: 'a-system-name',
      updated_at: 1.day.from_now,
      created_at: 1.day.from_now,
      account_id: @provider.id + 1
    }
  end
end
