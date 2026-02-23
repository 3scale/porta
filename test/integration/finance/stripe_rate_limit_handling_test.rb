# frozen_string_literal: true

require 'test_helper'

class Finance::StripeRateLimitHandlingTest < ActionDispatch::IntegrationTest
  include BillingResultsTestHelpers

  setup do
    @provider = FactoryBot.create(:provider_with_billing)
    @provider.billing_strategy.update(charging_enabled: true)

    @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)

    @time = Time.zone.now.beginning_of_month
  end

  teardown do
    clear_billing_locks
  end

  # ==================== Unit Tests for Rate Limit Detection ====================

  test 'StripeChargeService#rate_limit_error? detects rate limit from Stripe error code' do
    service = prepare_stripe_charge_service

    response = stub(
      success?: false,
      params: { 'error' => { 'code' => 'rate_limit' } }
    )

    assert service.send(:rate_limit_error?, response),
           'Should detect rate limit from Stripe rate_limit error code'
  end

  test 'StripeChargeService#rate_limit_error? does not false-positive on other errors' do
    service = prepare_stripe_charge_service

    response = stub(
      success?: false,
      params: { 'error' => { 'code' => 'card_declined' } }
    )

    assert_not service.send(:rate_limit_error?, response),
               'Should not detect rate limit for other error codes'
  end

  test 'StripeChargeService#rate_limit_error? does not detect rate limit on successful response' do
    service = prepare_stripe_charge_service

    response = stub(
      success?: true,
      params: {}
    )

    assert_not service.send(:rate_limit_error?, response),
               'Should not detect rate limit on successful response'
  end

  # ==================== Integration Tests for Invoice Charging ====================

  test 'Invoice charge re-raises RateLimitError when Stripe returns rate limit error' do
    Account.any_instance.expects(:charge!).raises(create_rate_limit_error)

    invoice = prepare_invoice

    # Should raise RateLimitError (to bubble up to BillingWorker)
    error = assert_raises(Finance::Payment::GatewayRateLimitError) do
      invoice.charge!
    end

    assert_instance_of Finance::Payment::GatewayRateLimitError, error

    # Invoice should NOT be marked as unpaid
    invoice.reload
    assert_not_equal 'unpaid', invoice.state
    assert_equal 'pending', invoice.state

    # Retry counter should NOT be incremented
    assert_equal 0, invoice.charging_retries_count
    assert_nil invoice.last_charging_retry
  end

  test 'Invoice charge handles regular payment errors differently than rate limits' do
    Account.any_instance.expects(:charge!).raises(Finance::Payment::CreditCardError, "Card declined")

    invoice = prepare_invoice

    # Should NOT raise (gets caught and handled)
    assert_nothing_raised do
      invoice.charge!
    end

    # Invoice should be marked as unpaid for regular errors
    assert_equal 'unpaid', invoice.reload.state

    # Retry counter should be incremented
    assert_equal 1, invoice.charging_retries_count
    assert_not_nil invoice.last_charging_retry
  end

  # ==================== BillingWorker Retry Logic Tests ====================

  test 'BillingWorker uses Sidekiq default exponential backoff for rate limit errors' do
    rate_limit_error = create_rate_limit_error

    # Returns nil to use Sidekiq's default exponential backoff
    retry_delay = BillingWorker.sidekiq_retry_in_block.call(1, rate_limit_error)
    assert_nil retry_delay, "Should return nil to use Sidekiq's default exponential backoff"
  end

  test 'BillingWorker uses standard retry delay for non-rate-limit errors' do
    regular_error = Finance::Payment::CreditCardError.new

    retry_delay = BillingWorker.sidekiq_retry_in_block.call(1, regular_error)

    # Should wait 1 hour + 10 seconds for lock release
    expected_delay = 1.hour + 10
    assert_equal expected_delay, retry_delay
  end

  # ==================== Job-Level Integration Tests ====================

  test 'BillingService re-raises rate limit error and releases lock' do
    Account.any_instance.expects(:charge!).raises(create_rate_limit_error)

    invoice = prepare_invoice

    # Should raise RateLimitError and not suppress it
    error = assert_raises(Finance::Payment::GatewayRateLimitError) do
      Finance::BillingService.call!(@buyer.id, provider_account_id: @provider.id, now: invoice.due_on)
    end

    assert_instance_of Finance::Payment::GatewayRateLimitError, error

    # Lock should be released - we can acquire it again immediately
    lock_service = Synchronization::BillingLockService.new(@buyer.id.to_s)
    assert_nothing_raised do
      lock_service.lock
    end
    lock_service.unlock
  end

  test 'rate limit error flow through BillingWorker' do
    Account.any_instance.expects(:charge!).raises(create_rate_limit_error)

    invoice = prepare_invoice

    # Perform billing worker job - should raise RateLimitError
    worker = BillingWorker.new

    error = assert_raises(Finance::Payment::GatewayRateLimitError) do
      worker.perform(@buyer.id, @provider.id, invoice.due_on.to_fs(:iso8601))
    end

    # Verify the error is the one we expect
    assert_instance_of Finance::Payment::GatewayRateLimitError, error

    # Verify invoice state is unchanged
    assert_equal 'pending', invoice.reload.state
  end

  # ==================== Safety: No Double Charging ====================

  test 'successful charge followed by rate limit does not double charge on retry' do
    invoice1 = prepare_invoice_with_id('00000001')
    invoice2 = prepare_invoice_with_id('00000002')

    billing_time = invoice1.due_on

    # First attempt: Invoice 1 succeeds, Invoice 2 hits rate limit
    call_sequence = sequence('charging')
    Account.any_instance.expects(:charge!).with(invoice1.cost, invoice: invoice1).returns(true).in_sequence(call_sequence)
    Account.any_instance.expects(:charge!).with(invoice2.cost, invoice: invoice2).raises(create_rate_limit_error).in_sequence(call_sequence)

    # Job fails with rate limit
    assert_raises(Finance::Payment::GatewayRateLimitError) do
      Finance::BillingService.call!(@buyer.id, provider_account_id: @provider.id, now: billing_time)
    end

    # Invoice 1 is paid, Invoice 2 is still pending
    assert_equal 'paid', invoice1.reload.state
    assert_equal 'pending', invoice2.reload.state

    clear_billing_locks

    # Retry: Only Invoice 2 should be charged (Invoice 1 excluded by chargeable scope)
    Account.any_instance.expects(:charge!).with(invoice2.cost, invoice: invoice2).returns(true).once

    # Retry succeeds
    assert_nothing_raised do
      Finance::BillingService.call!(@buyer.id, provider_account_id: @provider.id, now: billing_time)
    end

    # Both invoices now paid
    assert_equal 'paid', invoice1.reload.state
    assert_equal 'paid', invoice2.reload.state
  end

  # ==================== Edge Cases ====================

  test 'multiple rate limit errors do not increment retry counter' do
    invoice = prepare_invoice

    # First rate limit error
    Account.any_instance.expects(:charge!).raises(create_rate_limit_error)
    assert_raises(Finance::Payment::GatewayRateLimitError) { invoice.charge! }
    assert_equal 0, invoice.reload.charging_retries_count

    # Second rate limit error
    Account.any_instance.expects(:charge!).raises(create_rate_limit_error)
    assert_raises(Finance::Payment::GatewayRateLimitError) { invoice.charge! }
    assert_equal 0, invoice.reload.charging_retries_count

    # Invoice should still be in pending state, not failed
    assert_equal 'pending', invoice.reload.state
  end

  test 'rate limit followed by successful charge' do
    invoice = prepare_invoice

    # First attempt: rate limit
    Account.any_instance.expects(:charge!).raises(create_rate_limit_error)
    assert_raises(Finance::Payment::GatewayRateLimitError) { invoice.charge! }

    # Second attempt: success
    Account.any_instance.expects(:charge!).returns(true)
    invoice.charge!

    assert_equal 'paid', invoice.reload.state
    assert_equal 0, invoice.charging_retries_count
  end

  test 'rate limit followed by card declined' do
    invoice = prepare_invoice

    # First attempt: rate limit
    Account.any_instance.expects(:charge!).raises(create_rate_limit_error)
    assert_raises(Finance::Payment::GatewayRateLimitError) { invoice.charge! }
    assert_equal 0, invoice.reload.charging_retries_count

    # Second attempt: card declined
    Account.any_instance.expects(:charge!).raises(Finance::Payment::CreditCardError)
    invoice.charge!

    assert_equal 'unpaid', invoice.reload.state
    assert_equal 1, invoice.charging_retries_count
  end

  private

  def prepare_stripe_charge_service(invoice: nil)
    invoice ||= prepare_invoice
    gateway = stub('gateway')
    Finance::StripeChargeService.new(
      gateway,
      payment_method_id: 'pm_test',
      invoice: invoice,
      gateway_options: {}
    )
  end

  def create_rate_limit_error
    response = stub(
      success?: false,
      params: { 'error' => { 'code' => 'rate_limit' } },
      message: 'Request rate limit exceeded'
    )
    payment_metadata = {
      invoice_id: 123,
      buyer_id: 456,
      payment_method_id: 'pm_test',
      gateway_options: {}
    }
    Finance::Payment::GatewayRateLimitError.new(response, payment_metadata)
  end

  def prepare_invoice
    prepare_invoice_with_id('00000001')
  end

  def prepare_invoice_with_id(invoice_number)
    invoice = FactoryBot.create(:invoice,
                                period: Month.new(@time),
                                provider_account: @provider,
                                buyer_account: @buyer,
                                friendly_id: "#{@time.strftime('%Y-%m')}-#{invoice_number}")

    billing = Finance::BackgroundBilling.new(invoice)
    billing.create_line_item!(name: 'API Services', cost: 100.00, description: 'Monthly fee', quantity: 1)
    invoice.issue_and_pay_if_free!

    # Make it ready to charge (not recently retried)
    invoice.update_columns(
      due_on: Time.zone.now.to_date - 1.day,
      last_charging_retry: nil
    )

    invoice
  end
end
