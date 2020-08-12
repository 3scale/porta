# frozen_string_literal: true

require 'test_helper'

class CinstanceDecoratorTest < Draper::TestCase
  test '#account_admin_user_display_name' do
    contract = FactoryBot.build(:simple_cinstance)
    expected_display_name = contract.user_account.decorate.admin_user_display_name
    assert_equal expected_display_name, contract.decorate.account_admin_user_display_name
  end
end
