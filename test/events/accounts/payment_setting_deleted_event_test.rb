require 'test_helper'

class Accounts::PaymentSettingDeletedEventTest < ActiveSupport::TestCase

  def test_create
	payment_gateway_setting = FactoryBot.build_stubbed(:payment_gateway_setting)
    account = FactoryBot.build_stubbed(:simple_provider, id: 1, payment_gateway_setting: payment_gateway_setting)
    event = Accounts::PaymentSettingDeletedEvent.create(payment_gateway_setting)

    assert event
    assert_equal event.account, account
    object_attributes = event.metadata[:object_attributes]
    assert_equal object_attributes[:gateway_settings], payment_gateway_setting.symbolized_settings
    assert_equal object_attributes[:gateway_type], payment_gateway_setting.gateway_type.to_s
  end

  def test_valid?
	payment_gateway_setting = FactoryBot.build_stubbed(:payment_gateway_setting)
	account = FactoryBot.build_stubbed(:simple_provider, id: 1, payment_gateway_setting: payment_gateway_setting)

	refute Accounts::PaymentSettingDeletedEvent.valid?(payment_gateway_setting)
	account.stubs(:provider?).returns(true)
	refute Accounts::PaymentSettingDeletedEvent.valid?(payment_gateway_setting)
	account.stubs(:scheduled_for_deletion?).returns(true)
	assert Accounts::PaymentSettingDeletedEvent.valid?(payment_gateway_setting)
  payment_gateway_setting.stubs(:configured?).returns(false)
	refute Accounts::PaymentSettingDeletedEvent.valid?(payment_gateway_setting)
  end
end
