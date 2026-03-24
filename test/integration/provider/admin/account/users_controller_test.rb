# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::Account::UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @provider             = FactoryBot.create :provider_account
    @default_ids          = [:partners]
    @services             = FactoryBot.create_list(:service, 3, account: @provider)
    @default_service_ids  = @services.first(2).map(&:id)
    @user                 = FactoryBot.create :simple_user, account: @provider, member_permission_ids: @default_ids,
                                              member_permission_service_ids: @default_service_ids

    login! @provider
  end

  attr_reader :provider

  test '#update member_permission_ids with an empty value clears the permissions' do
    assert_equal @default_ids, @user.member_permission_ids.to_a

    put provider_admin_account_user_path(@user), params: { user: { member_permission_ids: [''] } }

    assert_response :redirect
    assert_equal [], @user.reload.member_permission_ids.to_a
  end

  test '#update member_permission_ids with an array sets the permissions' do
    put provider_admin_account_user_path(@user), params: { user: { member_permission_ids: %w[partners finance] } }

    assert_response :redirect
    assert_equal %i[finance partners], @user.reload.member_permission_ids.to_a.sort
  end

  test '#update member_permission_ids with a single value sets the permission' do
    put provider_admin_account_user_path(@user), params: { user: { member_permission_ids: ['finance'] } }

    assert_response :redirect
    assert_equal %i[finance], @user.reload.member_permission_ids.to_a
  end

  test '#update member_permission_service_ids with empty string sets them to nil' do
    assert_equal @default_service_ids, @user.reload.member_permission_service_ids

    put provider_admin_account_user_path(@user), params: { user: { member_permission_service_ids: '' } }

    assert_response :redirect
    assert_nil @user.reload.member_permission_service_ids
  end

  test '#update member_permission_service_ids with ["[]"] sets them to empty array' do
    assert_equal @default_service_ids, @user.reload.member_permission_service_ids

    put provider_admin_account_user_path(@user), params: { user: { member_permission_service_ids: ['[]'] } }

    assert_response :redirect
    assert_equal [], @user.reload.member_permission_service_ids
  end

  test '#update member_permission_service_ids with "[]" string does not change existing ids' do
    assert_equal @default_service_ids, @user.reload.member_permission_service_ids

    put provider_admin_account_user_path(@user), params: { user: { member_permission_service_ids: '[]' } }

    assert_response :redirect
    assert_equal @default_service_ids, @user.reload.member_permission_service_ids
  end

  test '#update member_permission_service_ids with [""] sets them to empty array' do
    assert_equal @default_service_ids, @user.reload.member_permission_service_ids

    put provider_admin_account_user_path(@user), params: { user: { member_permission_service_ids: [''] } }

    assert_response :redirect
    assert_equal [], @user.reload.member_permission_service_ids
  end

  test '#update member_permission_service_ids with an array of ids sets them' do
    third_service_id = @services.last.id
    assert_not_includes @default_service_ids, third_service_id

    put provider_admin_account_user_path(@user), params: { user: { member_permission_service_ids: [third_service_id.to_s] } }

    assert_response :redirect
    assert_equal [third_service_id], @user.reload.member_permission_service_ids
  end

  test '#update with empty user' do
    assert_equal @default_ids, @user.member_permission_ids.to_a

    put provider_admin_account_user_path(@user), params: { user: {} }

    assert_equal @default_ids, @user.reload.member_permission_ids.to_a
  end

  test 'admin deletes another admin' do
    user = FactoryBot.create(:admin, account: provider)

    delete provider_admin_account_user_path(user.id)

    assert_raises(ActiveRecord::RecordNotFound) { user.reload }
  end

  test 'admin cannot delete himself' do
    user = provider.admin_users.first!

    delete provider_admin_account_user_path(user.id)

    assert user.reload
  end

  test 'admin changes role of another admin' do
    user = FactoryBot.create(:admin, account: provider)

    put provider_admin_account_user_path(user), params: { user: { role: 'member' } }

    assert user.reload.member?
  end

  test 'admin cannot edit his own role' do
    user = provider.admin_users.first!

    put provider_admin_account_user_path(user), params: { user: {role: 'member'} }

    assert user.reload.admin?
  end

  test 'member cannot change another user role' do
    member = FactoryBot.create(:member, account: provider, member_permission_ids: [:partners])
    member.activate!

    assert @user.member?

    login! provider, user: member

    put provider_admin_account_user_path(@user), params: { user: { role: 'admin' } }

    assert_response :forbidden
    assert @user.reload.member?
  end

  test 'edit page shows password fields for user with password' do
    get edit_provider_admin_account_user_path(@user)

    assert_response :success
    assert_select 'input[name="user[password]"]'
    assert_select 'input[name="user[password_confirmation]"]'
  end

  test 'edit page shows password fields for SSO user without password' do
    @user.update_columns(password_digest: nil, authentication_id: 'sso-user-id')

    get edit_provider_admin_account_user_path(@user)

    assert_response :success
    assert_select 'input[name="user[password]"]'
    assert_select 'input[name="user[password_confirmation]"]'
  end
end
