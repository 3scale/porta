# frozen_string_literal: true

require 'test_helper'

class Finance::TrialPeriodTimezoneTest < ActiveSupport::TestCase
  include TestHelpers::FakeHits

  # Trial expires Jan 15 00:00 UTC (14-day trial from Jan 1).
  # Usage is created at specific UTC times during and after trial.
  # Billing runs Feb 1 UTC (postpaid). Only post-trial usage should be billed.
  #
  # The 3 tests check how provider/buyer/server timezone affects
  # which usage gets billed - billing should always use UTC boundaries.

  setup do
    @original_tz = ENV.fetch('TZ', nil)
    @storage = Stats::Base.storage
    @storage.flushdb
    @provider_created_at = Time.zone.local(1983, 11, 1)
  end

  teardown do
    ENV['TZ'] = @original_tz
    @storage.flushdb
  end

  test 'trial period billing with Pacific timezone bills only post-trial usage' do
    # Pacific is UTC-8. Trial expires Jan 15 00:00 UTC = Jan 14 16:00 PST.
    # So in Pacific local time the trial is still "Jan 14" when it expires in UTC.
    run_trial_billing_test(timezone: 'Pacific Time (US & Canada)')
  end

  test 'trial period billing with UTC timezone bills only post-trial usage' do
    run_trial_billing_test(timezone: 'UTC')
  end

  test 'trial period billing with Tokyo timezone bills only post-trial usage' do
    # Tokyo is UTC+9. Trial expires Jan 15 00:00 UTC = Jan 15 09:00 JST.
    # So in Tokyo local time, trial expiration is well into Jan 15.
    run_trial_billing_test(timezone: 'Tokyo')
  end

  private

  def run_trial_billing_test(timezone:)
    ENV['TZ'] = timezone

    provider = FactoryBot.create(:provider_with_billing, created_at: @provider_created_at, timezone: timezone)

    buyer = FactoryBot.create(:buyer_account, provider_account: provider, created_at: Time.utc(2025, 1, 1), timezone: timezone)
    buyer.settings.update_attribute(:monthly_billing_enabled, true)

    contract = FactoryBot.create(:cinstance, user_account: buyer, service: provider.first_service!, created_at: Time.utc(2025, 1, 1))

    # Set trial to expire Jan 15 00:00 UTC (simulating a 14-day trial from Jan 1).
    # variable_cost_paid_until is nil so it falls back to trial_period_expires_at,
    # meaning billing starts from the trial expiration date.
    Cinstance.where(id: contract.id).update_all(
      trial_period_expires_at: Time.utc(2025, 1, 15),
      variable_cost_paid_until: nil
    )
    contract.reload

    metric = contract.service.metrics.hits
    contract.plan.pricing_rules.create!(metric: metric, cost_per_unit: 0.01)

    # Usage during trial period (before Jan 15 00:00 UTC) - should NOT be billed
    fake_hit(Time.utc(2025, 1, 3, 12, 0), 100, contract, metric)   # beginning of month, during trial
    fake_hit(Time.utc(2025, 1, 14, 23, 0), 200, contract, metric)  # just before trial expires

    # Usage after trial expiration (Jan 15 00:00 UTC onwards) - SHOULD be billed
    fake_hit(Time.utc(2025, 1, 15, 2, 0), 300, contract, metric)   # just after trial expired
    fake_hit(Time.utc(2025, 1, 30, 12, 0), 400, contract, metric)  # end of month

    # Travel to Feb 1 12:00 UTC - well within Feb 1 for all tested timezones:
    #   Pacific: Feb 1 04:00 PST, UTC: Feb 1 12:00, Tokyo: Feb 1 21:00 JST
    # Postpaid daily billing bills January variable costs on day 1.
    travel_to(Time.utc(2025, 2, 1, 12, 0))
    Finance::BillingStrategy.daily(only: [provider.id], skip_notifications: true)

    invoices = provider.buyer_invoices.reload
    assert_not_empty invoices

    invoice = invoices.last
    line_items = invoice.line_items.where(type: 'LineItem::VariableCost')
    total_hits = line_items.sum { |li| li.quantity.to_i }

    # Total cost should be 700 hits * 0.01 per hit = 7.00
    total_cost = line_items.sum(&:cost)
    assert_equal 7.00, total_cost.to_f,
                 "Expected total variable cost of 7.00 (700 hits * 0.01) with #{timezone} timezone, " \
                   "but got #{total_cost}."

    # Only post-trial hits should be billed: 300 + 400 = 700
    # Trial-period hits (100 + 200) should be excluded because
    # variable_cost_paid_until falls back to trial_period_expires_at (Jan 15),
    # so intersect_with_unpaid_period bills only from Jan 15 onwards.
    # Although including zero cost hits in the invoice will not be a bug
    # as long as the final price was the expected one.
    assert_equal 700, total_hits,
                 "Expected only post-trial hits (300 + 400 = 700) with #{timezone} timezone, " \
                 "but got #{total_hits}. Trial-period hits (100 + 200) should be excluded."
  end
end
