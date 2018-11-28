# frozen_string_literal: true

require 'test_helper'

class Admin::Api::MemberPermissionsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @provider = Factory(:provider_account, self_domain: 'example.org')
    FactoryGirl.create(:service, :id => 1, :account => @provider)
    FactoryGirl.create(:service, :id => 2, :account => @provider)
    @user = Factory(:active_user, account: @provider)

    login! @provider
  end

  test 'get' do
    get admin_api_permissions_path(id: @user.id, format: :json)
    assert_response :success
  end

  test "PUT: enable 'analytics' section for service 1" do
    params = { allowed_sections: ['monitoring'], allowed_service_ids: [1] }

    put admin_api_permissions_path(id: @user.id, format: :json), params

    permissions = JSON.parse(@response.body)['permissions']
    assert_equal ['monitoring'], permissions['allowed_sections']
    assert_equal [1], permissions['allowed_service_ids']
  end

  test "PUT: enable 'settings', but keep the same services" do
    @user.update_attributes({ allowed_sections: ['partners'], allowed_service_ids: [1] })
    params = { allowed_sections: ['settings'] }

    put admin_api_permissions_path(id: @user.id, format: :json), params

    permissions = JSON.parse(@response.body)['permissions']
    assert_equal ['settings'], permissions['allowed_sections']
    assert_equal [1], permissions['allowed_service_ids']
  end

  test "PUT: enable service '2', but keep the same sections" do
    @user.update_attributes({ allowed_sections: ['partners'], allowed_service_ids: [1] })
    params = { allowed_service_ids: ['2'] }

    put admin_api_permissions_path(id: @user.id, format: :json), params

    permissions = JSON.parse(@response.body)['permissions']
    assert_equal ['partners'], permissions['allowed_sections']
    assert_equal [2], permissions['allowed_service_ids']
  end

  test "PUT: enable 'settings' and enable all services" do
    # allowed_sections%5B%5D=settings&allowed_service_ids%5B%5D
    params = { allowed_sections: ['settings'], allowed_service_ids: nil }

    put admin_api_permissions_path(id: @user.id, format: :json), params

    permissions = JSON.parse(@response.body)['permissions']
    assert_equal ['settings'], permissions['allowed_sections']
    assert_nil permissions['allowed_service_ids']
  end

  test "PUT: enable 'settings', but disable all services" do
    # allowed_sections%5B%5D=settings&allowed_service_ids%5B%5D=%5B%5D
    params = { allowed_sections: ['settings'], allowed_service_ids: ["[]"] }

    put admin_api_permissions_path(id: @user.id, format: :json), params

    permissions = JSON.parse(@response.body)['permissions']
    assert_equal ['settings'], permissions['allowed_sections']
    assert_empty permissions['allowed_service_ids']
  end

  test "updating admin's permissions is not allowed" do
    @user.update_attribute :role, 'admin'
    params = { allowed_sections: ['monitoring'], allowed_service_ids: [1] }

    put admin_api_permissions_path(id: @user.id, format: :json), params

    assert_response :forbidden
    assert_equal '{"status":"Forbidden"}', @response.body
  end

  test "member user can't update his own permissions" do
    @user.update_attribute :role, 'member'
    provider_login @user

    params = { allowed_sections: ['settings'], allowed_service_ids: nil }

    put admin_api_permissions_path(id: @user.id, format: :json), params

    assert_response :forbidden
    assert_equal '{"status":"Forbidden"}', @response.body
  end

  # this is managed by CanCan abilities
  test "member user can't update other users' permissions" do
    logged_in_user = @provider.admins.first
    logged_in_user.update_attribute :role, 'member'
    another_user = Factory(:user, account: @provider)

    params = { allowed_sections: ['settings'], allowed_service_ids: nil }

    put admin_api_permissions_path(id: another_user.id, format: :json), params

    assert_response :forbidden
  end

  test "PUT: setting an invalid allowed section" do
    params = { allowed_sections: ['invalid'], allowed_service_ids: [1] }

    put admin_api_permissions_path(id: @user.id, format: :json), params

    assert_response :unprocessable_entity
    response = JSON.parse(@response.body)
    assert_equal ['invalid'], response['errors']['member_permissions']
  end

  test "PUT: setting services, when some are non-existent only enables existent ones" do
    @user.update_attributes({ allowed_sections: ['partners'], allowed_service_ids: [1] })
    params = { allowed_service_ids: ['2','22'] }

    put admin_api_permissions_path(id: @user.id, format: :json), params

    assert_response :success
    permissions = JSON.parse(@response.body)['permissions']
    assert_equal ['partners'], permissions['allowed_sections']
    assert_equal [2], permissions['allowed_service_ids']
  end

  test "PUT: setting non-existent services disables all" do
    @user.update_attributes({ allowed_sections: ['partners'], allowed_service_ids: [1] })
    params = { allowed_service_ids: ['22'] }

    put admin_api_permissions_path(id: @user.id, format: :json), params

    assert_response :success
    permissions = JSON.parse(@response.body)['permissions']
    assert_equal ['partners'], permissions['allowed_sections']
    assert_empty permissions['allowed_service_ids']
  end
  
end
