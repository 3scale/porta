require 'test_helper'

class Logic::BuyerTest < ActiveSupport::TestCase

  def setup
    @provider = FactoryBot.build_stubbed(:simple_provider)
    @billing_strategy = Finance::BillingStrategy.new
    @account = FactoryBot.build_stubbed(:simple_account)
    @account.stubs(provider_account: @provider)
    @provider.stubs(billing_strategy: @billing_strategy)
  end

  test 'is charged when charging is enabled' do
    @billing_strategy.stubs(charging_enabled?: true)
    assert @account.settings.monthly_charging_enabled?
    assert @account.is_charged?
  end

  test 'is not charged when provider charging is disabled' do
    @billing_strategy.stubs(charging_enabled?: false)
    assert @account.settings.monthly_charging_enabled?
    refute @account.is_charged?
  end

  test 'is not charged when account settings is disabled' do
    @billing_strategy.stubs(charging_enabled?: false)
    @account.settings.stubs(monthly_charging_enabled?: false)
    refute @account.is_charged?
  end

  test 'credit card is not needed if no plan' do
    assert_empty @account.bought_plans
    refute @account.credit_card_needed?
  end

  test 'credit card is needed if any bought plan' do
    @account.stubs(is_charged?: true)
    bought_plans = [
      mock(paid?: false),
      mock(paid?: false),
      mock(paid?: true)
    ]
    @account.stubs(bought_plans: bought_plans)
    assert @account.credit_card_needed?
  end

  test 'credit card is missing' do
    @account.stubs(credit_card_needed?: true)
    refute @account.credit_card_stored?
    assert @account.credit_card_missing?
  end

  test 'credit card is not missing' do
    @account.stubs(credit_card_needed?: false)
    refute @account.credit_card_stored?
    refute @account.credit_card_missing?

    @account.stubs(credit_card_needed?: true)
    @account.stubs(credit_card_stored?: true)
    refute @account.credit_card_missing?
  end

  test 'credit card is editable' do
    @provider.stubs(payment_gateway_configured?: true)
    @billing_strategy.stubs(charging_enabled?: true)
    assert @account.credit_card_editable?

    @provider.stubs(payment_gateway_configured?: false)
    @billing_strategy.stubs(charging_enabled?: true)
    refute @account.credit_card_editable?

    @provider.stubs(payment_gateway_configured?: true)
    @billing_strategy.stubs(charging_enabled?: false)
    # FIXME: I do not see any valid reason why it is not editable here
    refute @account.credit_card_editable?
  end

  test 'requires credit card on paid plans' do
    @provider.stubs(payment_gateway_configured?: true)

    @billing_strategy.stubs(charging_enabled?: true)
    @account.stubs(is_charged?: true)
    bought_plans = [false, false, true].map{|b| m = mock; m.stubs(paid?: b); m}
    @account.stubs(bought_plans: bought_plans)

    @provider.settings.require_cc_on_signup_switch = 'hidden'
    refute @account.requires_credit_card_now?

    @provider.settings.require_cc_on_signup_switch = 'visible'
    assert @account.requires_credit_card_now?

    bought_plans.pop
    refute @account.requires_credit_card_now?
  end
end
