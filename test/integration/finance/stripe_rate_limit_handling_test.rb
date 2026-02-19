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

  test 'PaymentTransaction detects rate limit from HTTP 429 status code' do
    transaction = PaymentTransaction.new

    response = stub(
      success?: false,
      params: { 'error' => { 'http_code' => 429 } },
      message: 'Rate limit exceeded'
    )

    assert transaction.send(:rate_limit_error?, response),
           'Should detect rate limit from HTTP 429 status code'
  end

  test 'PaymentTransaction detects rate limit from error message' do
    transaction = PaymentTransaction.new

    response = stub(
      success?: false,
      params: {},
      message: 'Too many requests - please try again later'
    )

    assert transaction.send(:rate_limit_error?, response),
           'Should detect rate limit from error message'
  end

  test 'PaymentTransaction does not false-positive on other errors' do
    transaction = PaymentTransaction.new

    response = stub(
      success?: false,
      params: { 'error' => { 'http_code' => 402 } },
      message: 'Card declined'
    )

    assert_not transaction.send(:rate_limit_error?, response),
               'Should not detect rate limit for other error codes'
  end

  # ==================== Integration Tests for Invoice Charging ====================

  test 'Invoice charge re-raises RateLimitError when Stripe returns 429' do
    Account.any_instance.expects(:charge!).raises(Finance::Payment::RateLimitError.new)

    invoice = prepare_invoice

    # Should raise RateLimitError (to bubble up to BillingWorker)
    error = assert_raises(Finance::Payment::RateLimitError) do
      invoice.charge!
    end

    assert_instance_of Finance::Payment::RateLimitError, error

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

  test 'BillingWorker uses exponential backoff for rate limit errors' do
    rate_limit_error = Finance::Payment::RateLimitError.new

    # First retry: ~15 seconds (3^1 * 5 = 15)
    retry_delay_1 = BillingWorker.sidekiq_retry_in_block.call(1, rate_limit_error)
    assert retry_delay_1 >= 15, "First retry should be >= 15 seconds, got #{retry_delay_1}"
    assert retry_delay_1 <= 25, "First retry should be <= 25 seconds (with jitter), got #{retry_delay_1}"

    # Second retry: ~45 seconds (3^2 * 5 = 45)
    retry_delay_2 = BillingWorker.sidekiq_retry_in_block.call(2, rate_limit_error)
    assert retry_delay_2 >= 45, "Second retry should be >= 45 seconds, got #{retry_delay_2}"
    assert retry_delay_2 <= 55, "Second retry should be <= 55 seconds (with jitter), got #{retry_delay_2}"

    # Third retry: ~135 seconds (3^3 * 5 = 135)
    retry_delay_3 = BillingWorker.sidekiq_retry_in_block.call(3, rate_limit_error)
    assert retry_delay_3 >= 135, "Third retry should be >= 135 seconds, got #{retry_delay_3}"
    assert retry_delay_3 <= 145, "Third retry should be <= 145 seconds (with jitter), got #{retry_delay_3}"
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
    Account.any_instance.expects(:charge!).raises(Finance::Payment::RateLimitError.new)

    invoice = prepare_invoice

    # Should raise RateLimitError and not suppress it
    error = assert_raises(Finance::Payment::RateLimitError) do
      Finance::BillingService.call!(@buyer.id, provider_account_id: @provider.id, now: invoice.due_on)
    end

    assert_instance_of Finance::Payment::RateLimitError, error

    # Lock should be released - we can acquire it again immediately
    assert_nothing_raised do
      Finance::BillingService.new(@buyer.id, provider_account_id: @provider.id, now: invoice.due_on).send(:acquire_lock)
    end
  end

  test 'rate limit error flow through BillingWorker' do
    Account.any_instance.expects(:charge!).raises(Finance::Payment::RateLimitError.new)

    invoice = prepare_invoice

    # Perform billing worker job - should raise RateLimitError
    worker = BillingWorker.new

    error = assert_raises(Finance::Payment::RateLimitError) do
      worker.perform(@buyer.id, @provider.id, invoice.due_on.to_fs(:iso8601))
    end

    # Verify the error is the one we expect
    assert_instance_of Finance::Payment::RateLimitError, error

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
    Account.any_instance.expects(:charge!).with(invoice2.cost, invoice: invoice2).raises(Finance::Payment::RateLimitError.new).in_sequence(call_sequence)

    # Job fails with rate limit
    assert_raises(Finance::Payment::RateLimitError) do
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
    Account.any_instance.expects(:charge!).raises(Finance::Payment::RateLimitError.new)
    assert_raises(Finance::Payment::RateLimitError) { invoice.charge! }
    assert_equal 0, invoice.reload.charging_retries_count

    # Second rate limit error
    Account.any_instance.expects(:charge!).raises(Finance::Payment::RateLimitError.new)
    assert_raises(Finance::Payment::RateLimitError) { invoice.charge! }
    assert_equal 0, invoice.reload.charging_retries_count

    # Invoice should still be in pending state, not failed
    assert_equal 'pending', invoice.reload.state
  end

  test 'rate limit followed by successful charge' do
    invoice = prepare_invoice

    # First attempt: rate limit
    Account.any_instance.expects(:charge!).raises(Finance::Payment::RateLimitError.new)
    assert_raises(Finance::Payment::RateLimitError) { invoice.charge! }

    # Second attempt: success
    Account.any_instance.expects(:charge!).returns(true)
    invoice.charge!

    assert_equal 'paid', invoice.reload.state
    assert_equal 0, invoice.charging_retries_count
  end

  test 'rate limit followed by card declined' do
    invoice = prepare_invoice

    # First attempt: rate limit
    Account.any_instance.expects(:charge!).raises(Finance::Payment::RateLimitError.new)
    assert_raises(Finance::Payment::RateLimitError) { invoice.charge! }
    assert_equal 0, invoice.reload.charging_retries_count

    # Second attempt: card declined
    Account.any_instance.expects(:charge!).raises(Finance::Payment::CreditCardError)
    invoice.charge!

    assert_equal 'unpaid', invoice.reload.state
    assert_equal 1, invoice.charging_retries_count
  end

  private

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
