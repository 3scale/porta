require 'test_helper'

class Provider::Admin::Account::UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @provider    = FactoryBot.create :provider_account
    @default_ids = [:partners]
    @user        = FactoryBot.create :simple_user, account: @provider, member_permission_ids: @default_ids

    login! @provider
  end

  attr_reader :provider

  def test_update_blank_member_permission_ids
    assert_equal @default_ids, @user.admin_sections.to_a

    put provider_admin_account_user_path(@user), user: {member_permission_ids: ['']}

    @user.reload

    assert_equal [], @user.admin_sections.to_a
  end

  def test_update_no_member_permission_ids
    assert_equal @default_ids, @user.admin_sections.to_a

    put provider_admin_account_user_path(@user), user: {}

    @user.reload

    assert_equal @default_ids, @user.admin_sections.to_a
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

    put provider_admin_account_user_path(user), user: {role: 'member'}

    assert user.reload.member?
  end

  test 'admin cannot edit his own role' do
    user = provider.admin_users.first!

    put provider_admin_account_user_path(user), user: {role: 'member'}

    assert user.reload.admin?
  end
end
