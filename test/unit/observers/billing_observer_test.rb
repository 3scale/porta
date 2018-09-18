require 'test_helper'

class BillingObserverTest < ActiveSupport::TestCase

  include FieldsDefinitionsHelpers

  disable_transactional_fixtures!

  setup do
    @service = FactoryGirl.create(:service, account: master_account)
    @plan = FactoryGirl.create(:application_plan, issuer: @service)

    field_defined(master_account, { target: 'Account', 'name' => 'red_hat_account_number' })

    provider_account = FactoryGirl.create(:simple_provider)
    provider_account.extra_fields = { 'red_hat_account_number' => 'my_rh_login' }
    provider_account.save

    @contract = FactoryGirl.create(:application_contract, plan: @plan, user_account: provider_account)
  end

  def test_plan_change
    new_plan = Factory(:application_plan, issuer: @service, cost_per_month: 50)
    invoice = FactoryGirl.create(:invoice)
    line_item = FactoryGirl.create(:line_item_plan_cost, invoice: invoice)

    @contract.buyer_account.provider_account.billing_strategy.expects(:bill_plan_change).returns(line_item)
    SupportEntitlementsService.expects(:notify_entitlements).with(@contract.account, { previous_plan: @plan, invoice: invoice })

    @contract.change_plan!(new_plan)
  end
end
