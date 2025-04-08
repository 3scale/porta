# frozen_string_literal: true

require 'test_helper'

# WARNING: flakiness in these tests means a bug
class Finance::BillingServiceIntegrationTest < ActionDispatch::IntegrationTest
  include BillingResultsTestHelpers

  attr_reader :provider, :buyer

  setup do
    @provider = FactoryBot.create(:provider_account, :with_billing)
    @buyer = FactoryBot.create(:buyer_account, provider_account: provider)
  end

  teardown do
    clear_billing_locks
  end

  class ConcurrentBillingCalls < Finance::BillingServiceIntegrationTest
    disable_transactional_fixtures!

    setup do
      provider.billing_strategy.update(charging_enabled: true)
    end

    test "concurrent billing calls without transaction" do
      concurrent_billing_check(isolation: :none)
    end

    test "simple failed charging in current thread" do
      Account.any_instance.expects(:charge!).raises(Finance::Payment::CreditCardError, "for the heck of it")
      invoice = prepare_invoice
      Finance::BillingService.call!(buyer.id, provider_account_id: provider.id, now: invoice.due_on)
      assert_equal "unpaid", invoice.reload.state
    end

    test "simple successful charging in current thread" do
      Account.any_instance.expects(:charge!).returns(true).once
      invoice = prepare_invoice
      Finance::BillingService.call!(buyer.id, provider_account_id: provider.id, now: invoice.due_on)
      assert_equal "paid", invoice.reload.state
    end

    test "fail then succeed payment" do
      Account.any_instance.expects(:charge!).raises(Finance::Payment::CreditCardError, "for the heck of it").once
      invoice = prepare_invoice
      Finance::BillingService.call!(buyer.id, provider_account_id: provider.id, now: invoice.due_on)
      assert_equal "unpaid", invoice.reload.state

      invoice.update({ last_charging_retry: invoice.last_charging_retry - 4.days }, without_protection: true)
      Finance::BillingService.call!(buyer.id, provider_account_id: provider.id, now: invoice.due_on)
      assert_equal "unpaid", invoice.reload.state

      clear_billing_locks

      Account.any_instance.expects(:charge!).returns(true).once
      Finance::BillingService.call!(buyer.id, provider_account_id: provider.id, now: invoice.due_on)
      assert_equal "paid", invoice.reload.state
    end
  end

  private

  def concurrent_billing_check(isolation: nil)
    # verify that the actual charging was attempted only once regardless of how many times Invoice#charge! was called
    Account.any_instance.expects(:charge!).with { true }.returns(true).times(10)

    assert_not ActiveRecord::Base.connection.transaction_open?

    10.times do |iteration|
      concurrent_billing_perform(iteration: iteration, isolation: isolation)
      clear_billing_locks
    end
  end

  def concurrent_billing_perform(iteration: 1, isolation: nil)
    invoice = prepare_invoice(iteration: iteration)

    workers = Array.new(3) do
      Thread.new do
        Thread.current.report_on_exception = false
        # the billing service call is expected to eventually invoke invoice.charge!
        Finance::BillingService.call!(buyer.id, provider_account_id: provider.id, now: invoice.due_on)
      end
    end

    workers.each(&:join)

    # make sure operation was successful once (or more, hopefully once but that is checked by expectation above)
    assert_equal "paid", invoice.reload.state
  end

  def prepare_invoice(iteration: 1)
    invoice = FactoryBot.create(:invoice,
                                period: Month.new(Time.zone.now.beginning_of_month),
                                provider_account: provider,
                                buyer_account: buyer,
                                friendly_id: "0000-00-0000000#{iteration}")
    billing = Finance::BackgroundBilling.new(invoice)
    billing.create_line_item!(name: 'Fake', cost: 1.233, description: 'really', quantity: 1)
    invoice.issue_and_pay_if_free!
    assert_not_equal "paid", invoice.reload.state
    invoice
  end
end
