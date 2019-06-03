# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::Account::UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)
    login! provider
  end

  attr_reader :provider

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
