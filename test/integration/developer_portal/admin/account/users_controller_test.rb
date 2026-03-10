# frozen_string_literal: true

require 'test_helper'

class DeveloperPortal::Admin::Account::UsersControllerTest < ActionDispatch::IntegrationTest
  include System::UrlHelpers.cms_url_helpers

  def setup
    @provider = FactoryBot.create(:provider_account)
    @provider.settings.update!(useraccountarea_enabled: true)

    @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
    @buyer.buy! @provider.default_service.service_plans.first

    @member = FactoryBot.create(:member, account: @buyer)
    @member.activate!
  end

  test '#update admin can change another user role' do
    login_buyer @buyer

    assert @member.member?

    put admin_account_user_path(@member), params: { user: { role: 'admin' } }

    assert_response :redirect
    assert @member.reload.admin?
  end

  test '#update admin cannot change own role' do
    login_buyer @buyer

    admin = @buyer.admins.first!

    put admin_account_user_path(admin), params: { user: { role: 'member' } }

    assert admin.reload.admin?
  end

  test '#update admin can update another user' do
    login_buyer @buyer

    put admin_account_user_path(@member), params: { user: { username: 'new_username' } }

    assert_response :redirect
    @member.reload
    assert_equal 'new_username', @member.username
  end

  test '#update member cannot update another user' do
    target = FactoryBot.create(:member, account: @buyer)
    target.activate!

    login_buyer @buyer, @member

    put admin_account_user_path(target), params: { user: { username: 'new_username' } }

    assert_response :forbidden
  end

  test '#update member can update own attributes' do
    login_buyer @buyer, @member

    put admin_account_user_path(@member), params: { user: { username: 'updated_name' } }

    assert_response :redirect
    assert_equal 'updated_name', @member.reload.username
  end

  test '#update member cannot change own role' do
    login_buyer @buyer, @member

    assert @member.reload.member?

    put admin_account_user_path(@member), params: { user: { role: 'admin' } }

    assert @member.reload.member?
  end

  test '#update saves extra fields' do
    login_buyer @buyer

    FactoryBot.create(:fields_definition, account: @provider, target: 'User', name: 'custom_field')

    put admin_account_user_path(@member), params: { user: { custom_field: 'custom_value' } }

    assert_response :redirect
    assert_equal 'custom_value', @member.reload.extra_fields['custom_field']
  end

  test '#update filters read-only fields' do
    login_buyer @buyer

    FactoryBot.create(:fields_definition, account: @provider, target: 'User',
                                       name: 'first_name', read_only: true)

    @member.update!(first_name: 'Original')

    put admin_account_user_path(@member), params: { user: { first_name: 'Changed' } }

    assert_response :redirect
    assert_equal 'Original', @member.reload.first_name
  end
end
