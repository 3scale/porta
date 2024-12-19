# frozen_string_literal: true

require 'test_helper'

class Admin::Api::MemberPermissionsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @provider = FactoryBot.create(:provider_account)
    service_ids = FactoryBot.create_list(:simple_service, 2, account: provider).pluck(:id)
    @service1_id = service_ids.first
    @service2_id = service_ids.last
    @nonexistent_id = service_ids.max + 1
    @user = FactoryBot.create(:active_user, account: provider)
    @token = FactoryBot.create(:access_token, owner: provider.admin_users.first!, scopes: %w[account_management]).value

    host! provider.external_admin_domain
  end

  attr_reader :provider, :service1_id, :service2_id, :nonexistent_id, :user, :token

  test 'get' do
    get admin_api_permissions_path(id: user.id, format: :json, access_token: token)
    permissions = JSON.parse(response.body)['permissions']

    assert_response :success
    assert_equal %w[allowed_sections allowed_service_ids links role user_id], permissions.keys.sort
    assert_equal %w[href rel], permissions['links'].first.keys.sort
  end

  test "PUT: enable 'analytics' section for service 1" do
    params = { allowed_sections: ['monitoring'], allowed_service_ids: [service1_id], access_token: token }

    put admin_api_permissions_path(id: user.id, format: :json), params: params

    assert_not_nil(permissions = JSON.parse(response.body)['permissions'])
    assert_equal ['monitoring'], permissions['allowed_sections']
    assert_equal [service1_id], permissions['allowed_service_ids']

    user.member_permissions.reload
    assert_equal [:monitoring], user.allowed_sections.to_a
    assert_equal [service1_id], user.allowed_service_ids
  end

  test "PUT: enable 'settings', but keep the same services" do
    user.update({ allowed_sections: ['partners'], allowed_service_ids: [service1_id] })
    params = { allowed_sections: ['settings'], access_token: token }

    put admin_api_permissions_path(id: user.id, format: :json), params: params

    assert_not_nil(permissions = JSON.parse(response.body)['permissions'])
    assert_equal ['settings'], permissions['allowed_sections']
    assert_equal [service1_id], permissions['allowed_service_ids']

    user.member_permissions.reload
    assert_equal [:settings], user.allowed_sections.to_a
    assert_equal [service1_id], user.allowed_service_ids
  end

  test "PUT: enable service 2, but keep the same sections" do
    user.update({ allowed_sections: ['partners'], allowed_service_ids: [service1_id] })
    params = { allowed_service_ids: [service2_id.to_s], access_token: token }

    put admin_api_permissions_path(id: user.id, format: :json), params: params

    assert_not_nil(permissions = JSON.parse(response.body)['permissions'])
    assert_equal ['partners'], permissions['allowed_sections']
    assert_equal [service2_id], permissions['allowed_service_ids']

    user.member_permissions.reload
    assert_equal [:partners], user.allowed_sections.to_a
    assert_equal [service2_id], user.allowed_service_ids
  end

  test "PUT: enable 'settings' and enable all services" do
    user.update({ allowed_sections: ['partners'], allowed_service_ids: [service1_id] })
    # allowed_sections%5B%5D=settings&allowed_service_ids%5B%5D
    params = { allowed_sections: ['settings'], allowed_service_ids: '', access_token: token }

    put admin_api_permissions_path(id: user.id, format: :json), params: params

    assert_not_nil(permissions = JSON.parse(response.body)['permissions'])
    assert_equal ['settings'], permissions['allowed_sections']
    assert_nil permissions['allowed_service_ids']

    user.member_permissions.reload
    assert_equal [:settings], user.allowed_sections.to_a
    assert_nil user.allowed_service_ids
  end

  test "PUT: enable 'settings', but disable all services" do
    user.update({ allowed_service_ids: [service1_id] })
    # allowed_sections%5B%5D=settings&allowed_service_ids%5B%5D=%5B%5D
    params = { allowed_sections: ['settings'], allowed_service_ids: [""], access_token: token }

    put admin_api_permissions_path(id: user.id, format: :json), params: params

    assert_not_nil(permissions = JSON.parse(response.body)['permissions'])
    assert_equal ['settings'], permissions['allowed_sections']
    assert_empty permissions['allowed_service_ids']

    user.member_permissions.reload
    assert_equal [:settings], user.allowed_sections.to_a
    assert_empty user.allowed_service_ids
  end

  # This way was previously documented in ActiveDocs, so keeping it for backwards compatibility
  test "PUT: disable all services with `[]` value" do
    user.update({ allowed_service_ids: [service1_id] })
    # allowed_service_ids%5B%5D=%5B%5D
    params = { allowed_service_ids: ["[]"], access_token: token }

    put admin_api_permissions_path(id: user.id, format: :json), params: params

    assert_not_nil(permissions = JSON.parse(response.body)['permissions'])
    assert_empty permissions['allowed_service_ids']

    user.member_permissions.reload
    assert_equal [], user.allowed_service_ids
  end

  test "updating admin's permissions is not allowed" do
    user.update_attribute :role, 'admin'
    params = { allowed_sections: ['monitoring'], allowed_service_ids: [service1_id], access_token: token }

    put admin_api_permissions_path(id: user.id, format: :json), params: params

    assert_response :forbidden
    assert_equal '{"status":"Forbidden"}', response.body
  end

  test "member user can't update his own permissions" do
    user.update_attribute :role, 'member'
    token = FactoryBot.create(:access_token, owner: user, scopes: %w[account_management]).value
    # allowed_sections%5B%5D=settings&allowed_service_ids%5B%5D
    params = { allowed_sections: ['settings'], allowed_service_ids: '', access_token: token }

    put admin_api_permissions_path(id: user.id, format: :json), params: params

    assert_response :forbidden
    assert_equal '{"error":"Your access token does not have the correct permissions"}', response.body
  end

  # this is managed by CanCan abilities
  test "member user can't update other users' permissions" do
    logged_in_user = provider.admins.first
    logged_in_user.update_attribute :role, 'member'
    another_user = FactoryBot.create(:user, account: provider)
    # allowed_sections%5B%5D=settings&allowed_service_ids%5B%5D
    params = { allowed_sections: ['settings'], allowed_service_ids: '', access_token: token }

    put admin_api_permissions_path(id: another_user.id, format: :json), params: params

    assert_response :forbidden
  end

  test "PUT: setting an invalid allowed section" do
    user.update({ allowed_sections: ['partners'], allowed_service_ids: [service1_id] })
    params = { allowed_sections: ['invalid'], access_token: token }

    put admin_api_permissions_path(id: user.id, format: :json), params: params

    assert_response :success
    assert_not_nil(permissions = JSON.parse(response.body)['permissions'])
    assert_empty permissions['allowed_sections']
    assert_equal [service1_id], permissions['allowed_service_ids']

    user.member_permissions.reload
    assert_empty user.allowed_sections.to_a
    assert_equal [service1_id], user.allowed_service_ids
  end

  test "PUT: one of the allowed section is invalid" do
    user.update({ allowed_sections: ['partners'], allowed_service_ids: [service1_id] })
    params = { allowed_sections: %w[invalid settings], access_token: token }

    put admin_api_permissions_path(id: user.id, format: :json), params: params

    assert_response :success
    assert_not_nil(permissions = JSON.parse(response.body)['permissions'])
    assert_equal ['settings'], permissions['allowed_sections']
    assert_equal [service1_id], permissions['allowed_service_ids']

    user.member_permissions.reload
    assert_equal [:settings], user.allowed_sections.to_a
    assert_equal [service1_id], user.allowed_service_ids
  end

  test "PUT: setting services, when some are non-existent only enables existent ones" do
    user.update({ allowed_sections: ['partners'], allowed_service_ids: [service1_id] })
    params = { allowed_service_ids: [service2_id.to_s, nonexistent_id.to_s], access_token: token }

    put admin_api_permissions_path(id: user.id, format: :json), params: params

    assert_response :success
    assert_not_nil(permissions = JSON.parse(response.body)['permissions'])
    assert_equal ['partners'], permissions['allowed_sections']
    assert_equal [service2_id], permissions['allowed_service_ids']

    user.member_permissions.reload
    assert_equal [:partners], user.allowed_sections.to_a
    assert_equal [service2_id], user.allowed_service_ids
  end

  test "PUT: setting non-existent services disables all" do
    user.update({ allowed_sections: ['partners'], allowed_service_ids: [service1_id] })
    params = { allowed_service_ids: [nonexistent_id.to_s], access_token: token }

    put admin_api_permissions_path(id: user.id, format: :json), params: params

    assert_response :success
    assert_not_nil(permissions = JSON.parse(response.body)['permissions'])
    assert_equal ['partners'], permissions['allowed_sections']
    assert_empty permissions['allowed_service_ids']

    user.member_permissions.reload
    assert_equal [:partners], user.allowed_sections.to_a
    assert_empty user.allowed_service_ids
  end

  test 'disable all allowed_sections' do
    user.update({ allowed_sections: ['partners'], allowed_service_ids: [service1_id] })

    put admin_api_permissions_path(id: user.id, format: :json, access_token: token), params: { allowed_sections: ['[]'] }

    user.member_permissions.reload
    assert_empty user.allowed_sections.to_a
  end

end
