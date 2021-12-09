require 'test_helper'

class SupportEntitlementsServiceTest < ActiveSupport::TestCase
  include FieldsDefinitionsHelpers
  include ActiveJob::TestHelper

  setup do
    @service = FactoryBot.create(:service, account: master_account)

    field_defined(master_account, { target: 'Account', 'name' => 'red_hat_account_number' })
    @provider_account = FactoryBot.create(:simple_provider)
    @provider_account.extra_fields = { 'red_hat_account_number' => 'my_rh_login' }
    @provider_account.save

    FactoryBot.create(:simple_admin, account: @provider_account, username: 'john_doe')

    @free_plan = FactoryBot.create(:application_plan, issuer: @service)
    @paid_plan = FactoryBot.create(:application_plan, issuer: @service, cost_per_month: 50)
    @enterprise_plan = FactoryBot.create(:application_plan, issuer: @service, system_name: "2017_fake_#{Logic::ProviderUpgrade::ENTERPRISE_PLAN}_3M")
    @trial_plan = FactoryBot.create(:application_plan, issuer: @service)
    @trial_plan.plan_rule.metadata = {trial: true}
  end

  test 'notifications can be disabled' do
    @provider_account.buy! @paid_plan

    ThreeScale.config.redhat_customer_portal.stubs(entitlements_notifications_enabled: false)
    refute SupportEntitlementsService.notify_entitlements(@provider_account)

    ThreeScale.config.redhat_customer_portal.stubs(entitlements_notifications_enabled: true)
    assert SupportEntitlementsService.notify_entitlements(@provider_account)
  end

  test '#notify_entitlements paid plan' do
    @provider_account.buy! @paid_plan

    invoice = FactoryBot.create(:invoice, buyer_account: @provider_account, issued_on: Time.parse('2017-11-05'))
    FactoryBot.create(:line_item_plan_cost, invoice: invoice, contract: @provider_account.bought_cinstance, cinstance_id: @provider_account.bought_cinstance.id)

    AccountMailer.expects(:support_entitlements_assigned).with(@provider_account, effective_since: invoice.issued_on, invoice_id: invoice.id).returns(mock(deliver_later: true))
    AccountMailer.expects(:support_entitlements_revoked).never

    assert SupportEntitlementsService.notify_entitlements(@provider_account)
  end

  test '#notify_entitlements free plan' do
    @provider_account.buy! @free_plan

    AccountMailer.expects(:support_entitlements_assigned).never
    AccountMailer.expects(:support_entitlements_revoked).never

    refute SupportEntitlementsService.notify_entitlements(@provider_account)
  end

  test '#notify_entitlements trial plan' do
    @provider_account.buy! @trial_plan

    Timecop.freeze do
      AccountMailer.expects(:support_entitlements_assigned).with(@provider_account, effective_since: Time.now.utc).returns(mock(deliver_later: true))
      AccountMailer.expects(:support_entitlements_revoked).never

      assert SupportEntitlementsService.notify_entitlements(@provider_account)
    end
  end

  test '#notify_entitlements paid to trial' do
    @provider_account.buy! @trial_plan

    Timecop.freeze do
      AccountMailer.expects(:support_entitlements_assigned).never
      AccountMailer.expects(:support_entitlements_revoked).with(@provider_account, effective_since: Time.now.utc).returns(mock(deliver_later: true))

      entitlements_options = { previous_plan: @paid_plan }
      assert SupportEntitlementsService.notify_entitlements(@provider_account, entitlements_options)
    end
  end

  test '#notify_entitlements free to trial' do
    @provider_account.buy! @trial_plan

    Timecop.freeze do
      AccountMailer.expects(:support_entitlements_assigned).with(@provider_account, effective_since: Time.now.utc).returns(mock(deliver_later: true))
      AccountMailer.expects(:support_entitlements_revoked).never

      entitlements_options = { previous_plan: @free_plan }
      assert SupportEntitlementsService.notify_entitlements(@provider_account, entitlements_options)
    end
  end

  test '#notify_entitlements paid to paid' do
    @provider_account.buy! @paid_plan
    other_paid_plan = FactoryBot.create(:application_plan, issuer: @service, cost_per_month: 100)
    invoice = FactoryBot.create(:invoice, buyer_account: @provider_account, issued_on: Time.parse('2017-11-05'))

    AccountMailer.expects(:support_entitlements_assigned).never
    AccountMailer.expects(:support_entitlements_revoked).never

    entitlements_options = { previous_plan: other_paid_plan, invoice: invoice }
    refute SupportEntitlementsService.notify_entitlements(@provider_account, entitlements_options)
  end

  test '#notify_entitlements free to paid' do
    @provider_account.buy! @paid_plan

    invoice = FactoryBot.create(:invoice, buyer_account: @provider_account, issued_on: Time.parse('2017-11-05'))

    AccountMailer.expects(:support_entitlements_assigned).with(@provider_account, effective_since: invoice.issued_on, invoice_id: invoice.id).returns(mock(deliver_later: true))
    AccountMailer.expects(:support_entitlements_revoked).never

    entitlements_options = { previous_plan: @free_plan, invoice: invoice }
    assert SupportEntitlementsService.notify_entitlements(@provider_account, entitlements_options)
  end

  test '#notify_entitlements paid to free' do
    @provider_account.buy! @free_plan

    Timecop.freeze do
      AccountMailer.expects(:support_entitlements_assigned).never
      AccountMailer.expects(:support_entitlements_revoked).with(@provider_account, effective_since: Time.now.utc).returns(mock(deliver_later: true))

      entitlements_options = { previous_plan: @paid_plan }
      assert SupportEntitlementsService.notify_entitlements(@provider_account, entitlements_options)
    end
  end

  test '#notify_entitlements free to free' do
    @provider_account.buy! @free_plan
    other_free_plan = FactoryBot.create(:application_plan, issuer: @service)

    AccountMailer.expects(:support_entitlements_assigned).never
    AccountMailer.expects(:support_entitlements_revoked).never

    entitlements_options = { previous_plan: other_free_plan }
    refute SupportEntitlementsService.notify_entitlements(@provider_account, entitlements_options)
  end

  test '#notify_entitlements suspended from paid' do
    @provider_account.buy! @paid_plan
    @provider_account.stubs(:recently_suspended?).returns(true)
    @provider_account.stubs(:approved?).returns(false)

    invoice = FactoryBot.create(:invoice, buyer_account: @provider_account, issued_on: Time.parse('2017-11-05'))
    FactoryBot.create(:line_item_plan_cost, invoice: invoice, contract: @provider_account.bought_cinstance, cinstance_id: @provider_account.bought_cinstance.id)

    AccountMailer.expects(:support_entitlements_assigned).never
    AccountMailer.expects(:support_entitlements_revoked).with(@provider_account, effective_since: invoice.issued_on, invoice_id: invoice.id).returns(mock(deliver_later: true))

    assert SupportEntitlementsService.notify_entitlements(@provider_account)
  end

  test '#notify_entitlements suspended from trial' do
    @provider_account.buy! @trial_plan
    @provider_account.stubs(:recently_suspended?).returns(true)
    @provider_account.stubs(:approved?).returns(false)

    AccountMailer.expects(:support_entitlements_assigned).never
    AccountMailer.expects(:support_entitlements_revoked).never

    refute SupportEntitlementsService.notify_entitlements(@provider_account)
  end

  test '#notify_entitlements suspended from free' do
    @provider_account.buy! @free_plan
    @provider_account.stubs(:recently_suspended?).returns(true)

    AccountMailer.expects(:support_entitlements_assigned).never
    AccountMailer.expects(:support_entitlements_revoked).never

    refute SupportEntitlementsService.notify_entitlements(@provider_account)
  end

  test '#notify_entitlements without invoice' do
    @provider_account.buy! @paid_plan

    Timecop.freeze do
      AccountMailer.expects(:support_entitlements_assigned).with(@provider_account, effective_since: Time.now.utc).returns(mock(deliver_later: true))
      AccountMailer.expects(:support_entitlements_revoked).never

      assert SupportEntitlementsService.notify_entitlements(@provider_account)
    end
  end
end
