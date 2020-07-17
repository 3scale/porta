# frozen_string_literal: true

require 'test_helper'

class AccountDecoratorTest < Draper::TestCase
  test '#admin_user_display_name' do
    account = FactoryBot.create(:simple_account)
    user = FactoryBot.create(:admin, account: account)
    account.reload

    decorator = account.decorate
    assert_equal user.decorate.display_name, decorator.admin_user_display_name
    assert_not_nil decorator.admin_user_display_name

    account_without_admin_user = Account.new
    assert_nil account_without_admin_user.decorate.admin_user_display_name
  end
end
