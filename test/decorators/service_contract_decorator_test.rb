# frozen_string_literal: true

require 'test_helper'

class ServiceContractDecoratorTest < Draper::TestCase
  test '#account_admin_user_display_name' do
    service_contract = FactoryBot.build(:service_contract)
    expected_display_name = service_contract.user_account.decorate.admin_user_display_name
    assert_equal expected_display_name, service_contract.decorate.account_admin_user_display_name
  end
end
