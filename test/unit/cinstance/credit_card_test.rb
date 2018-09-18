require 'test_helper'

# REFACTOR: totally remove that
class Cinstance::CreditCardTest < ActiveSupport::TestCase

  test 'Cinstance#credit_card_missing? returns true on postpaid billing/paid plan when credit card is not valid' do
    provider_account = Factory(:provider_account)
    provider_account.billing_strategy = Factory(:postpaid_billing, :charging_enabled => true)

    plan = Factory(:application_plan, :issuer => provider_account.default_service, :cost_per_month => 100)
    buyer_account = Factory(:buyer_account, :provider_account => provider_account)
    cinstance = buyer_account.buy!(plan)

    assert cinstance.credit_card_missing?
  end

  test 'Cinstance#credit_card_missing? returns false on postpaid billing/paid plan when credit card is valid' do
    provider_account = Factory(:provider_account)
    provider_account.billing_strategy = Factory(:postpaid_billing)

    plan = Factory(:application_plan, :issuer => provider_account.default_service, :cost_per_month => 100)
    buyer_account = Factory(:buyer_account, :provider_account => provider_account,
                            :credit_card_auth_code => 'code1')
    cinstance = buyer_account.buy!(plan)

    refute cinstance.credit_card_missing?
  end

  test 'Cinstance#credit_card_missing? returns false on postpaid billing/paid plan and in trial period when credit card is not valid' do
    provider_account = Factory(:provider_account)
    provider_account.billing_strategy = Factory(:postpaid_billing)

    plan = Factory(:application_plan, :issuer => provider_account.default_service, :cost_per_month => 100,
                   :trial_period_days => 30)
    buyer_account = Factory(:buyer_account, :provider_account => provider_account)
    cinstance = buyer_account.buy!(plan)

    refute cinstance.credit_card_missing?
  end

  test 'Cinstance#credit_card_missing? returns false on postpaid billing/free plan when credit card is not valid' do
    provider_account = Factory(:provider_account)
    provider_account.billing_strategy = Factory(:postpaid_billing)

    plan = Factory(:application_plan, :issuer => provider_account.default_service, :cost_per_month => 0)
    buyer_account = Factory(:buyer_account, :provider_account => provider_account)
    cinstance = buyer_account.buy!(plan)

    refute cinstance.credit_card_missing?
  end

  test 'Cinstance#credit_card_missing? returns false on informational billing/free plan when credit card is not valid' do
    provider_account = Factory(:provider_account)
    provider_account.billing_strategy = Factory(:postpaid_billing, :charging_enabled => false)

    plan = Factory(:application_plan, :issuer => provider_account.default_service, :cost_per_month => 0)
    buyer_account = Factory(:buyer_account, :provider_account => provider_account)
    cinstance = buyer_account.buy!(plan)

    refute cinstance.credit_card_missing?
  end

  test 'Cinstance#credit_card_missing? returns false on informational billing/paid plan when credit card is not valid' do
    provider_account = Factory(:provider_account)
    provider_account.billing_strategy = Factory(:postpaid_billing)

    plan = Factory(:application_plan, :issuer => provider_account.default_service, :cost_per_month => 100)
    buyer_account = Factory(:buyer_account, :provider_account => provider_account)
    cinstance = buyer_account.buy!(plan)

    refute cinstance.credit_card_missing?
  end
end
