# frozen_string_literal: true

require 'test_helper'

class Finance::BillingStrategyTimezoneTest < ActiveSupport::TestCase
  include TestHelpers::FakeHits

  # Pacific Time is UTC-8 in winter and UTC-7 during daylight saving time.
  setup do
    @original_tz = ENV['TZ']
    @storage = Stats::Base.storage
    @storage.flushdb

    provider_created_at = Time.zone.local(1983, 11, 1)
    @provider = FactoryBot.create(:provider_with_billing, created_at: provider_created_at, timezone: 'Pacific Time (US & Canada)')

    # Buyer and contract exist since beginning of the month
    buyer = FactoryBot.create(:buyer_account, provider_account: @provider, created_at: Time.utc(2025, 1, 1), timezone: 'Pacific Time (US & Canada)')
    buyer.settings.update_attribute(:monthly_billing_enabled, true)
    @contract = FactoryBot.create(:cinstance, user_account: buyer, service: @provider.first_service!, created_at: Time.utc(2025, 1, 1))
    # Set variable_cost_paid_until and trial_period_expires_at to nil so we can bill for January
    @contract.update_columns(variable_cost_paid_until: nil, trial_period_expires_at: nil)
    @metric = @contract.service.metrics.hits

    # Add pricing rule so there's something to bill
    @contract.plan.pricing_rules.create!(metric: @metric, cost_per_unit: 0.01)
  end

  teardown do
    ENV['TZ'] = @original_tz
  end

  test 'billing uses UTC regardless of provider and buyer timezones' do

    # NOTE: Usage is usually logged with UTC timestamps in Redis.
    # Apicast lacks an option to log usages in local timezone.
    # According to https://access.redhat.com/solutions/3418661 providers could do that though, so that billing applies to their time zone.
    # There's a risk with highly negative UTC offsets (e.g., Pacific) to miss the usages between the local time when billing is performed and the local end of day.
    # To avoid this, billing should be run after the local timezone day boundary has passed.
    # But we provide no standard mechanism to control when Billing is scheduled.

    # Hit 1: Dec 31 23:30 UTC = Dec 31 15:30 Pacific
    # This hit is on Dec 31 in UTC, so it should NOT be billed for January
    fake_hit(Time.utc(2024, 12, 31, 23, 30), 25, @contract, @metric)

    # Hit 2: Jan 1 00:30 UTC = Dec 31 16:30 Pacific (1st in UTC but still Dec 31 in Pacific)
    # This hit is billed for January because billing uses UTC dates
    fake_hit(Time.utc(2025, 1, 1, 0, 30), 50, @contract, @metric)

    # Hit 3: Jan 14 12:00 UTC = Jan 14 04:00 Pacific (clearly Jan 14 in both)
    fake_hit(Time.utc(2025, 1, 14, 12, 0), 100, @contract, @metric)

    # Hit 4: Feb 1 01:00 UTC = Jan 31 17:00 Pacific
    # This hit occurs on Feb 1 in UTC, so it should NOT be billed for January
    # Even though it's Jan 31 in Pacific time, billing uses UTC date
    fake_hit(Time.utc(2025, 2, 1, 1, 0), 500, @contract, @metric)

    # First attempt: Bill at Feb 1 00:01 UTC, but pass it as Pacific time (Jan 31 16:01 PST)
    # The only_on_days check uses now.day which is 31 (not 1), so monthly billing doesn't run
    # This is not necessarily how it should work, it is how it works at the time of writing.
    billing_time_pacific = Time.utc(2025, 2, 1, 0, 1).in_time_zone('Pacific Time (US & Canada)')
    Finance::BillingStrategy.daily(only: [@provider.id], now: billing_time_pacific, skip_notifications: true)

    invoices = @provider.buyer_invoices.reload
    assert_empty invoices, 'Should NOT create invoice when billing_time is in Pacific (day 31, not day 1)'

    # Second attempt: Bill at the same moment in time, but pass it as UTC (Feb 1 00:01 UTC)
    # The only_on_days check uses now.day which is 1, so monthly billing runs
    billing_time_utc = Time.utc(2025, 2, 1, 0, 1)
    Finance::BillingStrategy.daily(only: [@provider.id], now: billing_time_utc, skip_notifications: true)

    invoices = @provider.buyer_invoices.reload
    assert_not_empty invoices, 'Should create invoice when billing_time is in UTC (day 1)'

    invoice = invoices.last
    assert_equal 1, invoice.period.begin.month, 'Invoice period should start in January'
    assert_equal 1, invoice.period.begin.day, 'Invoice period should start on the 1st'
    assert_equal 1, invoice.period.end.month, 'Invoice period should end in January'
    assert_equal 31, invoice.period.end.day, 'Invoice period should end on the 31st'

    # Verify only January UTC hits are billed (Hit 2: 50 + Hit 3: 100 = 150)
    # Hit 1 (25) is Dec 31 UTC, Hit 4 (500) is Feb 1 UTC - neither should be included
    # This proves billing uses UTC dates, ignoring provider timezone
    line_items = invoice.line_items.where(type: 'LineItem::VariableCost')
    total_hits = line_items.sum { |li| li.quantity.to_i }
    assert_equal 150, total_hits, 'Should only bill hits from January in UTC, not provider timezone'
  end

  # This test validates that the day used for scheduling (e.g., monthly billing on day 1)
  # is determined by the timezone of the 'now' parameter, not UTC or provider timezone.
  # Not saying this is the ideal behavior but test prevents inadvertent change.
  # AFAICT currently we always call this with UTC anyways.
  test 'billing timezone of `now` parameter to determine current day' do
    fake_hit(Time.utc(2025, 1, 14, 12, 0), 100, @contract, @metric)

    # Same moment in time: Feb 1 00:01 UTC = Jan 31 16:01 Pacific
    utc_time = Time.utc(2025, 2, 1, 0, 1)
    pacific_time = utc_time.in_time_zone('Pacific Time (US & Canada)')

    # Verify they represent the same instant
    assert_equal utc_time.to_i, pacific_time.to_i

    # But they have different days
    assert_equal 1, utc_time.day, 'UTC time should be day 1'
    assert_equal 31, pacific_time.day, 'Pacific time should be day 31'

    # Monthly billing only runs on day 1
    # When passed Pacific time (day 31), monthly billing should be skipped
    # Set server TZ to UTC to prove it doesn't affect the result
    ENV['TZ'] = 'UTC'
    Finance::BillingStrategy.daily(only: [@provider.id], now: pacific_time, skip_notifications: true)
    assert_empty @provider.buyer_invoices.reload, 'Invoice created when now.day is 31 (Pacific)'

    # When passed UTC time (day 1), monthly billing should run
    # Set server TZ to Pacific to prove it doesn't affect the result
    ENV['TZ'] = 'America/Los_Angeles'
    Finance::BillingStrategy.daily(only: [@provider.id], now: utc_time, skip_notifications: true)
    assert_not_empty @provider.buyer_invoices.reload, 'Invoice not created when now.day is 1 (UTC)'
  end

  test 'billing default `now` is UTC when `now` parameter was not provided' do
    fake_hit(Time.utc(2025, 1, 14, 12, 0), 100, @contract, @metric)

    travel_to Time.utc(2025, 2, 1, 0, 1)

    # UTC is Feb 1 but in Los Angeles is Jan 31
    ENV['TZ'] = 'America/Los_Angeles'
    assert_equal 31, Time.now.day

    Finance::BillingStrategy.daily(only: [@provider.id], skip_notifications: true)
    assert_not_empty @provider.buyer_invoices.reload, 'Invoice not created when now.day should be 1 (UTC)'
  end

  test 'billing includes the spring DST transition and only the March UTC period once' do
    # The setup gives both accounts Pacific Time, but usage and billing periods use UTC.
    # March 1 at 00:30 UTC is still February 28 at 16:30 Pacific; it belongs to March's invoice.
    # On March 9, Pacific clocks jump from 01:59 to 03:00: the two transition hits
    # are at 01:30 PST and 03:30 PDT, respectively, even though they are one hour apart in UTC.
    # The helper records these hits and the month-boundary hits, then bills March twice.
    assert_billing_across_dst(
      before_period: Time.utc(2025, 2, 28, 23, 30),
      start_period: Time.utc(2025, 3, 1, 0, 30),
      before_transition: Time.utc(2025, 3, 9, 9, 30),
      after_transition: Time.utc(2025, 3, 9, 10, 30),
      end_period: Time.utc(2025, 3, 31, 23, 30),
      after_period: Time.utc(2025, 4, 1, 0, 30),
      billing_time: Time.utc(2025, 4, 1, 12),
      period_end: Date.new(2025, 3, 31)
    )
  end

  test 'billing includes both occurrences of the fall DST hour and only the November UTC period once' do
    # The accounts still use Pacific Time, while the invoice covers November in UTC.
    # November 1 at 00:30 UTC is October 31 at 17:30 Pacific; it belongs to November's invoice.
    # On November 2, clocks go back from 02:00 to 01:00. The transition hits are
    # both at 01:30 Pacific: the first is PDT (UTC-7), and the second is PST (UTC-8).
    # The helper records both occurrences and the month-boundary hits, then bills twice.
    assert_billing_across_dst(
      before_period: Time.utc(2025, 10, 31, 23, 30),
      start_period: Time.utc(2025, 11, 1, 0, 30),
      before_transition: Time.utc(2025, 11, 2, 8, 30),
      after_transition: Time.utc(2025, 11, 2, 9, 30),
      end_period: Time.utc(2025, 11, 30, 23, 30),
      after_period: Time.utc(2025, 12, 1, 0, 30),
      billing_time: Time.utc(2025, 12, 1, 12),
      period_end: Date.new(2025, 11, 30)
    )
  end

  private

  def assert_billing_across_dst(before_period:, start_period:, before_transition:, after_transition:, end_period:, after_period:, billing_time:, period_end:)
    ENV['TZ'] = 'UTC' # The provider and buyer use Pacific Time.
    # Billing currently uses UTC month boundaries: exclude the 200 and 400 hits
    # outside the month, and include the 10 + 20 + 40 + 80 hits inside it.
    { before_period => 200, start_period => 10, before_transition => 20,
      after_transition => 40, end_period => 80, after_period => 400 }.each do |time, quantity|
      fake_hit(time, quantity, @contract, @metric)
    end

    # Running billing twice should not charge for the same usage twice.
    2.times do
      Finance::BillingStrategy.daily(only: [@provider.id], now: billing_time, skip_notifications: true)
    end

    invoices = @provider.buyer_invoices.reload
    invoice = invoices.find { |item| item.period.end.to_date == period_end }
    assert_not_nil invoice
    items = invoice.line_items.where(type: 'LineItem::VariableCost')
    # The 150 in-period hits cost $1.50 at the $0.01 rate configured in setup.
    assert_equal 150, items.sum { |item| item.quantity.to_i }
    assert_equal BigDecimal('1.50'), items.sum(&:cost)
    # The contract stores the last billed date at midnight UTC. Across all invoices,
    # the total must remain 150 after the second billing run.
    assert_equal Time.utc(period_end.year, period_end.month, period_end.day), @contract.reload[:variable_cost_paid_until]
    assert_equal 150, LineItem::VariableCost.where(invoice_id: invoices.map(&:id)).sum(:quantity).to_i
  end
end
