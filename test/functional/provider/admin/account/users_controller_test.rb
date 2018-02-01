require 'test_helper'

class Provider::Admin::Account::UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @provider    = FactoryBot.create :provider_account
    @default_ids = [:partners]
    @user        = FactoryBot.create :simple_user, account: @provider, member_permission_ids: @default_ids

    login_provider @provider
  end

  def test_update_blank_member_permission_ids
    assert_equal @default_ids, @user.admin_sections.to_a

    put provider_admin_account_user_path(@user.id), params: {user: { member_permission_ids: [] }}

    @user.reload

    assert_equal [], @user.admin_sections.to_a
  end

  def test_update_no_member_permission_ids
    assert_equal @default_ids, @user.admin_sections.to_a

    put provider_admin_account_user_path(@user.id), params: {user: {}}

    @user.reload

    assert_equal @default_ids, @user.admin_sections.to_a
  end
end
