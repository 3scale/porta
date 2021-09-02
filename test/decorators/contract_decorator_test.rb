# frozen_string_literal: true

require 'test_helper'

class ContractDecoratorTest < Draper::TestCase
  test '#account_admin_user_display_name' do
    cinstance = FactoryBot.build(:simple_cinstance)
    expected_display_name = cinstance.user_account.decorate.admin_user_display_name
    assert_equal expected_display_name, cinstance.decorate.account_admin_user_display_name

    service_contract = FactoryBot.build(:service_contract, plan: FactoryBot.create(:service_plan))
    expected_display_name = service_contract.account.decorate.admin_user_display_name
    assert_equal expected_display_name, service_contract.decorate.account_admin_user_display_name
  end
end
