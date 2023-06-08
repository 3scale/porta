# frozen_string_literal: true

require 'test_helper'

class Finance::BillingServiceIntegrationTest < ActionDispatch::IntegrationTest
  include BillingResultsTestHelpers

  attr_reader :provider, :buyer

  setup do
    @provider = FactoryBot.create(:provider_with_billing)
    @buyer = FactoryBot.create(:buyer_account, provider_account: provider)
  end

  teardown do
    clear_locks
  end

  class ConcurrentBillingCalls < Finance::BillingServiceIntegrationTest
    disable_transactional_fixtures!

    setup do
      # provider.stubs(:payment_gateway_configured?).returns(true) # delete, not needed
      provider.billing_strategy.update(charging_enabled: true)
    end

    # WARNING: flakiness here means a bug
    test "concurrent billing calls without transaction" do
      concurrent_billing_check(isolation: :none)
    end

    # WARNING: flakiness here means a bug
    # test "concurrent billing calls with read_committed" do
    #   concurrent_billing_check(isolation: :read_committed)
    # end
    #
    # # WARNING: flakiness here means a bug
    # test "concurrent billing calls with repeatable_read" do
    #   concurrent_billing_check(isolation: :repeatable_read)
    # end
  end

  private

  def concurrent_billing_check(isolation: nil)
    # verify that the actual charging was attempted only once regardless of how many times Invoice#charge! was called
    Account.any_instance.expects(:charge!).with {sleep 1}.returns(true).times(10)

    assert_not ActiveRecord::Base.connection.transaction_open?

    10.times do |iteration|
      concurrent_billing_perform(iteration: iteration, isolation: isolation)
      clear_locks
    end
  end

  def concurrent_billing_perform(iteration: 1, isolation: nil)
    invoice = FactoryBot.create(:invoice,
                                period: Month.new(Time.zone.now.beginning_of_month),
                                provider_account: provider,
                                buyer_account: buyer,
                                friendly_id: "0000-00-0000000#{iteration}")
    billing = Finance::BackgroundBilling.new(invoice)
    billing.create_line_item!(name: 'Fake', cost: 1.233, description: 'really', quantity: 1)
    invoice.issue_and_pay_if_free!
    assert_not_equal "paid", invoice.reload.state

    workers = Array.new(3) do
      Thread.new do
        Thread.current.report_on_exception = false
        with_transaction_isolation(isolation) do
          # the billing service call is expected to eventually invoke invoice.charge!
          Finance::BillingService.call!(buyer.id, provider_account_id: provider.id, now: invoice.due_on)
        rescue ActiveRecord::RecordNotUnique => exception
          Rails.logger.error exception.inspect
          retry
        end
      end
    end

    workers.each(&:join)

    # make sure operation was successful once (or more, hopefully once but that is checked by expectation above)
    assert_equal "paid", invoice.reload.state
  end

  def with_transaction_isolation(isolation)
    case isolation
    when :none
      yield
    else
      ActiveRecord::Base.transaction(requires_new: true, isolation: isolation) do
        yield
      end
    end
  end
end
