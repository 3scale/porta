# frozen_string_literal: true

require 'test_helper'

# a lot of non-TZ simpler scenarios also exist in features/finance
module Finance
  class BillVariableForPlanChangedTest < ActiveSupport::TestCase
    attr_reader :contract, :account, :app_plan

    setup do
      @contract = FactoryBot.build_stubbed(:application_contract)
      @account  = FactoryBot.build_stubbed(:simple_account)
      @app_plan = FactoryBot.build_stubbed(:application_plan)

      @org_tz = ENV.fetch("TZ", nil)
    end

    teardown do
      ENV["TZ"] = @org_tz
    end

    test "bill for variable" do
      travel_to(15.days.ago) if Time.now.mday == 1 # rubocop:disable Rails/TimeZone -- we don't use timezones in billing

      contract.stubs(:provider_account).returns(account)
      account.stubs(:provider_can_use?).returns(true)

      contract.expects(:save).returns(true)
      contract.notify_observers(:bill_variable_for_plan_changed, app_plan)
    end

    # This test is describing current behavior which is inconsistent with billing_strategy_timezone_test.rb
    # where UTC is most prominently used for billing purposes.
    # So we may want to update `BillingObserver#bill_variable_for_plan_changed` to respect UTC at some point,
    # especially given BillingObserver#plan_change already uses UTC
    test "no variable billing on 1st day of month local time" do
      # this changes server and client local time to China Standard Time (+8)
      ENV["TZ"] = "Asia/Shanghai"

      # this is 4 hours before beginning of month in UTC and 4 after local
      travel_to(Time.now.utc.beginning_of_month - 4.hours)

      contract.stubs(:provider_account).returns(account)
      account.stubs(:provider_can_use?).returns(true)
      contract.stubs(:variable_cost_paid_until).returns(Time.now.to_date - 7.days) # rubocop:disable Rails/TimeZone -- intentional

      contract.expects(:save).never
      contract.notify_observers(:bill_variable_for_plan_changed, app_plan)
    end

    test "no variable billing if last billed until is today" do
      contract.stubs(:provider_account).returns(account)
      freeze_time
      contract.stubs(:variable_cost_paid_until).returns(Time.now.to_date) # rubocop:disable Rails/TimeZone -- we don't use timezones in billing
      account.stubs(:provider_can_use?).returns(true)

      contract.expects(:save).never
      contract.notify_observers(:bill_variable_for_plan_changed, app_plan)
    end
  end

  class PlanChangeTimezones < ActiveSupport::TestCase
    # include BillingResultsTestHelpers
    include TestHelpers::FakeHits

    def format_invoice_items(items)
      items.map { |i| "  [#{i.plan_id}, #{i.name}, #{i.description}, #{i.cost}]" }.join("\n")
    end

    def assert_invoice_items(invoice, expected_items)
      items = invoice.reload.line_items.to_a
      assert_equal expected_items.size, items.size,
                   "Expected #{expected_items.size} invoice items but got #{items.size}\n" \
                   "Actual items:\n" + format_invoice_items(items)
      expected_items.each do |plan, name, description, cost|
        match = items.find { |i| i.plan_id == plan.id && i.name == name && i.description == description && i.cost == cost }
        assert match, "Expected invoice to contain item: plan=#{plan.name}, name=#{name}, " \
                      "description=#{description}, cost=#{cost}\nActual items:\n" + format_invoice_items(items)
      end
    end

    setup do
      @original_tz = ENV.fetch('TZ', nil)
      @storage = Stats::Base.storage
      @storage.flushdb

      provider_created_at = Time.zone.local(1983, 11, 1)
      @provider = FactoryBot.create(:provider_account, created_at: provider_created_at, timezone: 'Pacific Time (US & Canada)')
      @provider.billing_strategy = FactoryBot.create(billing_strategy_factory, numbering_period: 'monthly')
      @provider.save!
      @provider.billing_strategy.update!(charging_enabled: true)

      # there is no way for buyers to set their timezone but make sure it doesn't affect the logic
      @buyer = FactoryBot.create(:buyer_account, provider_account: @provider, created_at: Time.utc(2025, 1, 1), timezone: 'Pacific Time (US & Canada)')
      @buyer.settings.update!(monthly_billing_enabled: true)

      @service = @provider.first_service!
      @metric = @service.metrics.hits

      # Create two plans with different costs
      @basic_plan = FactoryBot.create(:application_plan, issuer: @service, name: 'Basic', cost_per_month: 10)
      @premium_plan = FactoryBot.create(:application_plan, issuer: @service, name: 'Premium', cost_per_month: 50)

      # Add pricing rules for variable costs
      @basic_plan.pricing_rules.create!(metric: @metric, cost_per_unit: 0.01)
      @premium_plan.pricing_rules.create!(metric: @metric, cost_per_unit: 0.02)
    end

    teardown do
      ENV['TZ'] = @original_tz
    end

    def billing_strategy_factory
      :postpaid_billing
    end

    def enable_instant_bill_plan_change
      rolling_updates_on
      rolling_update(:instant_bill_plan_change, enabled: true)
    end

    def disable_instant_bill_plan_change
      rolling_updates_on
      rolling_update(:instant_bill_plan_change, enabled: false)
    end

    # Helper to create a contract with specific trial settings
    def create_contract(trial_period_expires_at: nil, variable_cost_paid_until: nil)
      contract = FactoryBot.create(:cinstance,
                                   user_account: @buyer,
                                   plan: @basic_plan,
                                   created_at: Time.utc(2025, 1, 1))
      Cinstance.where(id: contract.id).update_all(
        trial_period_expires_at: trial_period_expires_at,
        variable_cost_paid_until: variable_cost_paid_until
      )
      contract.reload
    end

    module NonTrialPrePaidSharedTests
      extend ActiveSupport::Concern

      included do
        test 'plan change in UTC near beginning of month' do
          ENV['TZ'] = 'UTC'

          fake_hit(Time.utc(2025, 1, 1, 0, 1), 50, @contract, @metric)
          fake_hit(Time.utc(2025, 1, 31, 23, 59), 100, @contract, @metric)
          fake_hit(Time.utc(2025, 2, 1, 0, 59), 200, @contract, @metric)
          fake_hit(Time.utc(2025, 2, 1, 1, 1), 400, @contract, @metric)
          fake_hit(Time.utc(2025, 2, 28, 23, 59), 800, @contract, @metric)
          fake_hit(Time.utc(2025, 3, 1, 0, 1), 1600, @contract, @metric)

          # Travel to just after UTC month start
          travel_to(Time.utc(2025, 2, 1, 1, 0))
          @contract.change_plan!(@premium_plan)

          invoices = @provider.buyer_invoices.reload

          # Instant: bill_variable_for_plan_changed at Feb 1 01:00 UTC.
          # Month.new(Time.now) = February (TZ=UTC). period_from = max(Jan 1, Feb 1) = Feb 1.
          # last_midnight = Feb 1 00:00. period = Feb 1 .. Feb 1 00:00 → empty!
          # So no instant variable cost billing (same as without instant on day 1).
          #
          # Prepaid unbilled → cross-month PeriodRangeCalculationError → billed path.
          assert_equal 1, invoices.count
          invoice_feb = invoices.last
          assert_equal 2, invoice_feb.period.begin.month

          # BUG: Refund of Basic for February even though Basic was never billed for February
          expected_feb_items = [
            [@basic_plan, "Refund ('Basic')", "February  1, 2025 ( 1:00) - February 28, 2025 (23:59)", -9.99],
            [@premium_plan, "Application upgrade ('Basic' to 'Premium')", "February  1, 2025 ( 1:00) - February 28, 2025 (23:59)", 49.93]
          ]
          assert_invoice_items invoice_feb, expected_feb_items

          # Daily billing on Feb 1
          travel_to(Time.utc(2025, 2, 1, 12, 0))
          Finance::BillingStrategy.daily(only: [@provider.id], skip_notifications: true)

          # Prepaid: January variable costs on February invoice.
          # variable_cost_paid_until = Jan 1 (instant was a no-op, so never updated).
          # BUG: hits billed under Premium instead of Basic
          # BUG: paid_until was set to Feb 28 by plan_changed, so bill_fixed_costs skips.
          # BUG: paid_until was set to Feb 28 by plan_changed, so bill_fixed_costs skips
          assert_invoice_items invoice_feb.reload, expected_feb_items + [
            [@premium_plan, "Hits", "January  1, 2025 ( 0:00) - January 31, 2025 (23:59)", 3]
          ]

          # Daily billing on Mar 1
          travel_to(Time.utc(2025, 3, 1, 12, 0))
          Finance::BillingStrategy.daily(only: [@provider.id], skip_notifications: true)

          invoices = @provider.buyer_invoices.reload.order(:period)
          invoice_mar = invoices.select { |i| i.period.begin.month == 3 }.last
          assert_not_nil invoice_mar
          assert_invoice_items invoice_mar, [
            [@premium_plan, "Fixed fee ('Premium')", "March  1, 2025 ( 0:00) - March 31, 2025 (23:59)", 50],
            [@premium_plan, "Hits", "February  1, 2025 ( 0:00) - February 28, 2025 (23:59)", 28]
          ]
        end
      end
    end

    module NonTrialPostPaidSharedTests
      extend ActiveSupport::Concern

      included do
        test 'plan change in UTC near beginning of month' do
          # Keep server in UTC which is the only supported configuration
          ENV['TZ'] = 'UTC'

          # Create usage in January and February UTC
          fake_hit(Time.utc(2025, 1, 1, 0, 1), 50, @contract, @metric)
          fake_hit(Time.utc(2025, 1, 31, 23, 59), 100, @contract, @metric)
          fake_hit(Time.utc(2025, 2, 1, 0, 59), 200, @contract, @metric)
          fake_hit(Time.utc(2025, 2, 1, 1, 1), 400, @contract, @metric)
          fake_hit(Time.utc(2025, 2, 28, 23, 59), 800, @contract, @metric)
          fake_hit(Time.utc(2025, 3, 1, 0, 1), 1600, @contract, @metric)

          # Travel to just after UTC month start
          travel_to(Time.utc(2025, 2, 1, 1, 0))

          # Change plan from basic to premium
          @contract.change_plan!(@premium_plan)

          invoices = @provider.buyer_invoices.reload

          # bill_variable_for_plan_changed sees an empty billing period on day 1 of month
          assert_equal 1, invoices.count, 'Should have one invoice (February only, no January)'

          invoice_feb = invoices.last
          assert_equal 2, invoice_feb.period.begin.month, 'Invoice should be for February'
          assert_equal 28, invoice_feb.period.end.day, 'Invoice should end on Feb 28'

          # Only fixed cost items for February - no variable costs billed during plan change
          expected_feb_items = [
            [@basic_plan, "Fixed fee ('Basic')", "February  1, 2025 ( 0:00) - February 28, 2025 (23:59)", 10],
            [@basic_plan, "Refund ('Basic')", "February  1, 2025 ( 1:00) - February 28, 2025 (23:59)", -9.99],
            [@premium_plan, "Fixed fee ('Premium')", "February  1, 2025 ( 1:00) - February 28, 2025 (23:59)", 49.93]
          ]
          assert_invoice_items invoice_feb, expected_feb_items

          # Daily billing on Feb 1 (must be day 1 - PostpaidBillingStrategy only_on_days(now, 1))
          travel_to(Time.utc(2025, 2, 1, 12, 0))
          Finance::BillingStrategy.daily(only: [@provider.id], skip_notifications: true)
          assert_not invoice_feb.reload.finalized?

          invoices = @provider.buyer_invoices.reload.order(:period)
          assert_equal [1, 2], invoices.map { |i| i.period.begin.month },
                       'After Feb 1 billing, January and February invoices should exist'

          # January invoice is created and immediately finalized by daily billing
          # BUG: no fixed fee for January (Basic plan $10 is lost), maybe because Jan billing never run.
          #      on the other hand, the user might have been created in Jan, after the billing cycles so still a bug
          # BUG: hits are billed under Premium (current plan) instead of Basic (active during January)
          invoice_jan = invoices.first
          assert invoice_jan.finalized?, 'January invoice should be finalized'
          assert_invoice_items invoice_jan, [
            [@premium_plan, "Hits", "January  1, 2025 ( 0:00) - January 31, 2025 (23:59)", 3]
          ]

          # Daily billing on Mar 1 to finalize February
          travel_to(Time.utc(2025, 3, 1, 12, 0))
          Finance::BillingStrategy.daily(only: [@provider.id], skip_notifications: true)
          assert invoice_feb.reload.finalized?

          # Premium hits for February are added when the invoice is finalized
          assert_invoice_items invoice_feb, expected_feb_items + [
            [@premium_plan, "Hits", "February  1, 2025 ( 0:00) - February 28, 2025 (23:59)", 28]
          ]

          # March invoice is created by daily billing with Premium fixed fee for the new cycle
          invoices = @provider.buyer_invoices.reload.order(:period)
          assert_equal [1, 2, 3], invoices.map { |i| i.period.begin.month }

          invoice_mar = invoices.last
          assert_not invoice_mar.finalized?
          assert_invoice_items invoice_mar, [
            [@premium_plan, "Fixed fee ('Premium')", "March  1, 2025 ( 0:00) - March 31, 2025 (23:59)", 50]
          ]
        end
      end
    end

    class NonTrialPostPaidInstantTest < PlanChangeTimezones
      include NonTrialPostPaidSharedTests

      setup do
        enable_instant_bill_plan_change
        @contract = create_contract(trial_period_expires_at: nil, variable_cost_paid_until: nil)
      end

      # This test demonstrates the timezone discrepancy between BillingObserver#bill_variable_for_plan_changed
      # (uses server TZ via Time.now/Date.today) and BillingObserver#plan_changed (uses UTC via Time.now.utc).
      test 'plan change when in server TZ it is 1st but in UTC it is still 31st' do
        # Set server timezone to Shanghai (UTC+8)
        ENV['TZ'] = 'Asia/Shanghai'

        # Create usage in January UTC
        fake_hit(Time.utc(2025, 1, 1, 0, 1), 50, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 15, 12, 0), 100, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 30, 23, 59), 200, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 31, 12, 1), 400, @contract, @metric)
        fake_hit(Time.utc(2025, 2, 1, 0, 1), 800, @contract, @metric)

        # In UTC: Jan 31 23:00 (still January, day 31)
        # In Shanghai: Feb 1 07:00 (already February, day 1)
        travel_to Time.utc(2025, 1, 31, 23, 0)

        # Verify the timezone discrepancy
        assert_equal 31, Time.now.utc.day, 'UTC should be on the 31st'
        assert_equal 1, Time.now.day, 'Server local time (Shanghai) should be on the 1st' # rubocop:disable Rails/TimeZone

        # Change plan from basic to premium
        # This triggers both bill_variable_for_plan_changed and plan_changed
        @contract.change_plan!(@premium_plan)

        # Travel after last recorded usage for consistency, still 31st
        travel_to(Time.utc(2025, 1, 31, 23, 30))

        # Check invoices to see the actual behavior
        invoices = @provider.buyer_invoices.reload
        assert_equal 1, invoices.count, 'Should have created an invoice for January and items'

        # This test documents the current behavior, while it is possibly undesirable
        invoice = invoices.last
        assert_equal 1, invoice.period.begin.day, 'Invoice should be for January (starting day 1)'
        assert_equal 31, invoice.period.end.day, 'Invoice should be for January (ending day 31)'

        # #bill_variable_for_plan_changed uses Time.now (Shanghai = Feb 1)
        # It creates Month.new(Time.now) which is February
        # The billing period becomes empty on the 1st of the month
        #
        # #plan_changed uses Time.now.utc (Jan 31 20:00 UTC)
        #
        # TODO: I think we need to make #bill_variable_for_plan_changed use UTC too,
        #       or #plan_changed to respect TZ although former seems more consistent
        expected_jan_items = [
          [@basic_plan, "Fixed fee ('Basic')", "January  1, 2025 ( 0:00) - January 31, 2025 (23:59)", 10],
          [@basic_plan, "Refund ('Basic')", "January 31, 2025 (23:00) - January 31, 2025 (23:59)", -0.01],
          [@premium_plan, "Fixed fee ('Premium')", "January 31, 2025 (23:00) - January 31, 2025 (23:59)", 0.07]
        ]
        assert_invoice_items invoice, expected_jan_items

        # Now travel to Feb 1 to check final billing
        travel_to(Time.utc(2025, 2, 1, 0, 1))
        Finance::BillingStrategy.daily(only: [@provider.id], skip_notifications: true)

        # This seems like a BUG: all hits attributed to Premium plan, instead of just for the last day
        assert_invoice_items invoice, expected_jan_items + [
          [@premium_plan, "Hits", "January  1, 2025 ( 0:00) - January 31, 2025 (23:59)", 15]
        ]
      end

      test 'plan change in UTC near end of month' do
        # Keep server in UTC which is the only supported configuration
        ENV['TZ'] = 'UTC'

        # Create usage in January UTC
        fake_hit(Time.utc(2025, 1, 1, 0, 1), 50, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 15, 12, 0), 100, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 30, 23, 59), 200, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 31, 12, 1), 400, @contract, @metric)
        fake_hit(Time.utc(2025, 2, 1, 0, 1), 800, @contract, @metric)

        # Travel to just before UTC month end
        travel_to(Time.utc(2025, 1, 31, 23, 0))
        @contract.change_plan!(@premium_plan)
        travel_to(Time.utc(2025, 1, 31, 23, 30))

        invoices = @provider.buyer_invoices.reload
        assert_equal 1, invoices.count, 'Should have created an invoice for January and items'

        invoice = invoices.last
        assert_equal 1, invoice.period.begin.day, 'Invoice should be for January (starting day 1)'
        assert_equal 31, invoice.period.end.day, 'Invoice should be for January (ending day 31)'

        # it looks like that we bill variable cost for the full day when plan is changed
        # but fixed cost appears prorated based on the plan change time of the day
        # is this a BUG?
        expected_jan_items = [
          [@basic_plan, "Hits", "January  1, 2025 ( 0:00) - January 30, 2025 (23:59)", 3.5],
          [@basic_plan, "Fixed fee ('Basic')", "January  1, 2025 ( 0:00) - January 31, 2025 (23:59)", 10],
          [@basic_plan, "Refund ('Basic')", "January 31, 2025 (23:00) - January 31, 2025 (23:59)", -0.01],
          [@premium_plan, "Fixed fee ('Premium')", "January 31, 2025 (23:00) - January 31, 2025 (23:59)", 0.07]
        ]
        assert_invoice_items invoice, expected_jan_items

        # Now travel to Feb 1 to check final billing
        travel_to(Time.utc(2025, 2, 1, 0, 1))
        Finance::BillingStrategy.daily(only: [@provider.id], skip_notifications: true)
        assert invoice.reload.finalized?

        # Looks like a BUG: apparently we didn't add any lines for variable cost after plan change
        # expected would be: expected_jan_items + [
        #   [@premium_plan, "Hits", "January  31, 2025 ( 0:00) - January 31, 2025 (23:59)", 16]
        # ]
        assert_invoice_items invoice, expected_jan_items
      end

      test 'plan change when in server TZ it is 31st but in UTC it is already 1st' do
        # Set server timezone to Pacific (UTC-8)
        ENV['TZ'] = 'America/Los_Angeles'

        fake_hit(Time.utc(2025, 1, 1, 0, 1), 50, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 15, 12, 0), 100, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 30, 23, 59), 200, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 31, 12, 1), 400, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 31, 23, 59), 800, @contract, @metric)
        fake_hit(Time.utc(2025, 2, 1, 0, 1), 1600, @contract, @metric)

        # In UTC: Feb 1 01:00 (already February, day 1)
        # In Pacific: Jan 31 17:0 (still January, day 31)
        travel_to Time.utc(2025, 2, 1, 1, 0)

        @contract.change_plan!(@premium_plan)

        invoices = @provider.buyer_invoices.order(:period).to_a
        assert_equal 2, invoices.count

        invoice_jan = invoices.first
        invoice_feb = invoices.last

        items_jan = invoice_jan.line_items.to_a
        items_feb = invoice_feb.line_items.to_a

        assert_invoice_items invoice_jan, [
          [@basic_plan, "Hits", "January  1, 2025 ( 0:00) - January 30, 2025 (23:59)", 3.5]
        ]

        # it looks like that we bill variable cost for the full day when plan is changed
        # but fixed cost appears prorated based on the plan change time of the day
        # is this a BUG?
        expected_feb_items = [
          [@basic_plan, "Fixed fee ('Basic')", "February  1, 2025 ( 0:00) - February 28, 2025 (23:59)", 10],
          [@basic_plan, "Refund ('Basic')", "February  1, 2025 ( 1:00) - February 28, 2025 (23:59)", -9.99],
          [@premium_plan, "Fixed fee ('Premium')", "February  1, 2025 ( 1:00) - February 28, 2025 (23:59)", 49.93]
        ]
        assert_invoice_items invoice_feb, expected_feb_items

        travel_to Time.utc(2025, 2, 1, 12, 0)
        Finance::BillingStrategy.daily(only: [@provider.id], skip_notifications: true)

        assert invoice_jan.reload.finalized?
        # looks like a BUG: no fixes cost billed for Jan after Feb final billing
        # maybe if billing was performed at the begining of jan, that would be avoided,
        # but what if buyer was created mid-month?
        assert_equal items_jan, invoice_jan.line_items.reload.to_a
        assert_not invoice_feb.reload.finalized?
        assert_equal items_feb, invoice_feb.line_items.reload.to_a

        travel_to Time.utc(2025, 3, 1, 12, 0)
        Finance::BillingStrategy.daily(only: [@provider.id], skip_notifications: true)
        assert invoice_feb.reload.finalized?

        assert_equal items_jan, invoice_jan.line_items.reload.to_a # still fixed cost missing after March billing

        assert_invoice_items invoice_feb, expected_feb_items + [
          [@premium_plan, "Hits", "February  1, 2025 ( 0:00) - February 28, 2025 (23:59)", 32]
        ]
      end

      test "2 plan changes during a month billing with UTC (the only supported TZ)" do
        # Keep server in UTC which is the only supported configuration
        ENV['TZ'] = 'UTC'

        max_plan = FactoryBot.create(:application_plan, issuer: @service, name: 'Max', cost_per_month: 100)
        max_plan.pricing_rules.create!(metric: @metric, cost_per_unit: 0.04)

        fake_hit(Time.utc(2025, 1, 1, 0, 0), 25, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 6, 23, 59), 50, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 7, 12, 0), 100, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 14, 23, 59), 200, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 15, 12, 0), 400, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 31, 23, 59), 800, @contract, @metric)
        fake_hit(Time.utc(2025, 2, 1, 0, 1), 1600, @contract, @metric)

        travel_to Time.utc(2025, 1, 7, 12, 0)
        @contract.change_plan!(@premium_plan)
        # we don't care what happens mid-cycle, only the final invoice matters

        travel_to Time.utc(2025, 1, 15, 12, 0)
        @contract.change_plan!(max_plan)
        assert_equal 1, @provider.buyer_invoices.count
        # we don't care what happens mid-cycle, only the final invoice matters

        travel_to Time.utc(2025, 2, 1, 0, 1)
        Finance::BillingStrategy.daily(only: [@provider.id], skip_notifications: true)
        invoices = @provider.buyer_invoices.reload.to_a
        assert_equal 2, invoices.count

        invoice_jan = invoices.first
        invoice_feb = invoices.last
        assert invoice_jan.finalized?
        assert_not invoice_feb.finalized?

        assert_invoice_items invoice_jan, [
          [@basic_plan, "Hits", "January  1, 2025 ( 0:00) - January  6, 2025 (23:59)", 0.75],
          [@basic_plan, "Fixed fee ('Basic')", "January  1, 2025 ( 0:00) - January 31, 2025 (23:59)", 10],
          [@basic_plan, "Refund ('Basic')", "January  7, 2025 (12:00) - January 31, 2025 (23:59)", -7.9],
          [@premium_plan, "Fixed fee ('Premium')", "January  7, 2025 (12:00) - January 31, 2025 (23:59)", 39.52],
          [@premium_plan, "Hits", "January  7, 2025 ( 0:00) - January 14, 2025 (23:59)", 6],
          [@premium_plan, "Refund ('Premium')", "January 15, 2025 (12:00) - January 31, 2025 (23:59)", -26.61],
          [max_plan, "Fixed fee ('Max')", "January 15, 2025 (12:00) - January 31, 2025 (23:59)", 53.23],
          [max_plan, "Hits", "January 15, 2025 ( 0:00) - January 31, 2025 (23:59)", 48]
        ]
      end
    end

    class NonTrialPostPaidTest < PlanChangeTimezones
      include NonTrialPostPaidSharedTests

      setup do
        disable_instant_bill_plan_change
        @contract = create_contract(trial_period_expires_at: nil, variable_cost_paid_until: nil)
      end

      # Without instant_bill_plan_change, bill_variable_for_plan_changed is a no-op.
      # Variable costs are only billed during daily billing, using the CURRENT plan.

      test 'plan change when in server TZ it is 1st but in UTC it is still 31st' do
        ENV['TZ'] = 'Asia/Shanghai'

        fake_hit(Time.utc(2025, 1, 1, 0, 1), 50, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 15, 12, 0), 100, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 30, 23, 59), 200, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 31, 12, 1), 400, @contract, @metric)
        fake_hit(Time.utc(2025, 2, 1, 0, 1), 800, @contract, @metric)

        # In UTC: Jan 31 23:00 (still January, day 31)
        # In Shanghai: Feb 1 07:00 (already February, day 1)
        travel_to Time.utc(2025, 1, 31, 23, 0)

        assert_equal 31, Time.now.utc.day, 'UTC should be on the 31st'
        assert_equal 1, Time.now.day, 'Server local time (Shanghai) should be on the 1st' # rubocop:disable Rails/TimeZone

        @contract.change_plan!(@premium_plan)

        travel_to(Time.utc(2025, 1, 31, 23, 30))

        invoices = @provider.buyer_invoices.reload
        assert_equal 1, invoices.count, 'Should have one invoice for January'

        invoice = invoices.last
        assert_equal 1, invoice.period.begin.day, 'Invoice should be for January (starting day 1)'
        assert_equal 31, invoice.period.end.day, 'Invoice should be for January (ending day 31)'

        # Without instant: bill_variable_for_plan_changed is no-op.
        # Only plan_changed fires: bills fixed fee for Basic (full month),
        # refunds remaining period, bills Premium for remaining period.
        # No Hits line item at plan change time.
        expected_jan_items = [
          [@basic_plan, "Fixed fee ('Basic')", "January  1, 2025 ( 0:00) - January 31, 2025 (23:59)", 10],
          [@basic_plan, "Refund ('Basic')", "January 31, 2025 (23:00) - January 31, 2025 (23:59)", -0.01],
          [@premium_plan, "Fixed fee ('Premium')", "January 31, 2025 (23:00) - January 31, 2025 (23:59)", 0.07]
        ]
        assert_invoice_items invoice, expected_jan_items

        # Daily billing on Feb 1
        travel_to(Time.utc(2025, 2, 1, 0, 1))
        Finance::BillingStrategy.daily(only: [@provider.id], skip_notifications: true)

        # For non-instant billing this is the expected behavior - all usage as the new plan
        assert_invoice_items invoice, expected_jan_items + [
          [@premium_plan, "Hits", "January  1, 2025 ( 0:00) - January 31, 2025 (23:59)", 15]
        ]
      end

      test 'plan change in UTC near end of month' do
        ENV['TZ'] = 'UTC'

        fake_hit(Time.utc(2025, 1, 1, 0, 1), 50, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 15, 12, 0), 100, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 30, 23, 59), 200, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 31, 12, 1), 400, @contract, @metric)
        fake_hit(Time.utc(2025, 2, 1, 0, 1), 800, @contract, @metric)

        # Travel to just before UTC month end
        travel_to(Time.utc(2025, 1, 31, 23, 0))
        @contract.change_plan!(@premium_plan)
        travel_to(Time.utc(2025, 1, 31, 23, 30))

        invoices = @provider.buyer_invoices.reload
        assert_equal 1, invoices.count

        invoice = invoices.last
        assert_equal 1, invoice.period.begin.day, 'Invoice should be for January (starting day 1)'
        assert_equal 31, invoice.period.end.day, 'Invoice should be for January (ending day 31)'

        # Without instant: no variable cost billing at plan change.
        # Only fixed fee items from plan_changed.
        expected_jan_items = [
          [@basic_plan, "Fixed fee ('Basic')", "January  1, 2025 ( 0:00) - January 31, 2025 (23:59)", 10],
          [@basic_plan, "Refund ('Basic')", "January 31, 2025 (23:00) - January 31, 2025 (23:59)", -0.01],
          [@premium_plan, "Fixed fee ('Premium')", "January 31, 2025 (23:00) - January 31, 2025 (23:59)", 0.07]
        ]
        assert_invoice_items invoice, expected_jan_items

        # Daily billing on Feb 1
        travel_to(Time.utc(2025, 2, 1, 0, 1))
        Finance::BillingStrategy.daily(only: [@provider.id], skip_notifications: true)
        assert invoice.reload.finalized?

        # Without instant, variable costs are billed for Premium during daily billing for full January.
        # Usage: 50+100+200+400 = 750 hits, 750 * 0.02 = $15
        assert_invoice_items invoice, expected_jan_items + [
          [@premium_plan, "Hits", "January  1, 2025 ( 0:00) - January 31, 2025 (23:59)", 15]
        ]
      end

      test 'plan change when in server TZ it is 31st but in UTC it is already 1st' do
        ENV['TZ'] = 'America/Los_Angeles'

        fake_hit(Time.utc(2025, 1, 1, 0, 1), 50, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 15, 12, 0), 100, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 30, 23, 59), 200, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 31, 12, 1), 400, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 31, 23, 59), 800, @contract, @metric)
        fake_hit(Time.utc(2025, 2, 1, 0, 1), 1600, @contract, @metric)

        # In UTC: Feb 1 01:00 (already February)
        # In Pacific: Jan 31 17:00 (still January)
        travel_to Time.utc(2025, 2, 1, 1, 0)

        @contract.change_plan!(@premium_plan)

        # Without instant: no variable cost billing at plan change.
        # plan_changed uses Time.now.utc (Feb 1 01:00) → February period.
        # So only February invoice is created with fixed fee items.
        invoices = @provider.buyer_invoices.to_a
        assert_equal 1, invoices.count, 'Should have only February invoice (no instant billing for January)'

        invoice_feb = invoices.first

        expected_feb_items = [
          [@basic_plan, "Fixed fee ('Basic')", "February  1, 2025 ( 0:00) - February 28, 2025 (23:59)", 10],
          [@basic_plan, "Refund ('Basic')", "February  1, 2025 ( 1:00) - February 28, 2025 (23:59)", -9.99],
          [@premium_plan, "Fixed fee ('Premium')", "February  1, 2025 ( 1:00) - February 28, 2025 (23:59)", 49.93]
        ]
        assert_invoice_items invoice_feb, expected_feb_items

        travel_to Time.utc(2025, 2, 1, 12, 0)
        Finance::BillingStrategy.daily(only: [@provider.id], skip_notifications: true)

        # Daily billing creates January invoice with variable costs under Premium (current plan)
        # BUG: no fixed fee for January, all hits billed under Premium instead of Basic
        invoices = @provider.buyer_invoices.reload.order(:period)
        assert_equal [1, 2], invoices.map { |i| i.period.begin.month }

        invoice_jan = invoices.first
        assert invoice_jan.finalized?
        # Usage: 50+100+200+400+800 = 1550 hits at $0.02 = $31
        items_jan =[[@premium_plan, "Hits", "January  1, 2025 ( 0:00) - January 31, 2025 (23:59)", 31]]
        assert_invoice_items invoice_jan, items_jan

        assert_not invoice_feb.reload.finalized?
        assert_invoice_items invoice_feb, expected_feb_items

        travel_to Time.utc(2025, 3, 1, 12, 0)
        Finance::BillingStrategy.daily(only: [@provider.id], skip_notifications: true)
        assert invoice_feb.reload.finalized?

        assert_invoice_items invoice_jan, items_jan

        assert_invoice_items invoice_feb, expected_feb_items + [
          [@premium_plan, "Hits", "February  1, 2025 ( 0:00) - February 28, 2025 (23:59)", 32]
        ]
      end

      test "2 plan changes during a month billing with UTC (the only supported TZ)" do
        ENV['TZ'] = 'UTC'

        max_plan = FactoryBot.create(:application_plan, issuer: @service, name: 'Max', cost_per_month: 100)
        max_plan.pricing_rules.create!(metric: @metric, cost_per_unit: 0.04)

        fake_hit(Time.utc(2025, 1, 1, 0, 0), 25, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 6, 23, 59), 50, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 7, 12, 0), 100, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 14, 23, 59), 200, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 15, 12, 0), 400, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 31, 23, 59), 800, @contract, @metric)
        fake_hit(Time.utc(2025, 2, 1, 0, 1), 1600, @contract, @metric)

        travel_to Time.utc(2025, 1, 7, 12, 0)
        @contract.change_plan!(@premium_plan)
        # we don't care what happens mid-cycle, only the final invoice matters

        travel_to Time.utc(2025, 1, 15, 12, 0)
        @contract.change_plan!(max_plan)
        assert_equal 1, @provider.buyer_invoices.count
        # we don't care what happens mid-cycle, only the final invoice matters

        travel_to Time.utc(2025, 2, 1, 0, 1)
        Finance::BillingStrategy.daily(only: [@provider.id], skip_notifications: true)
        invoices = @provider.buyer_invoices.reload.to_a
        assert_equal 2, invoices.count

        invoice_jan = invoices.first
        invoice_feb = invoices.last
        assert invoice_jan.finalized?
        assert_not invoice_feb.finalized?

        # Without instant: no variable cost at plan change time.
        # Only fixed fee items from both plan changes. Daily billing adds all variable costs
        # under current plan (Max) for full January.
        # Usage: 25+50+100+200+400+800 = 1575 hits, 1575 * 0.04 = $63
        assert_invoice_items invoice_jan, [
          [@basic_plan, "Fixed fee ('Basic')", "January  1, 2025 ( 0:00) - January 31, 2025 (23:59)", 10],
          [@basic_plan, "Refund ('Basic')", "January  7, 2025 (12:00) - January 31, 2025 (23:59)", -7.9],
          [@premium_plan, "Fixed fee ('Premium')", "January  7, 2025 (12:00) - January 31, 2025 (23:59)", 39.52],
          [@premium_plan, "Refund ('Premium')", "January 15, 2025 (12:00) - January 31, 2025 (23:59)", -26.61],
          [max_plan, "Fixed fee ('Max')", "January 15, 2025 (12:00) - January 31, 2025 (23:59)", 53.23],
          [max_plan, "Hits", "January  1, 2025 ( 0:00) - January 31, 2025 (23:59)", 63]
        ]
      end
    end

    class NonTrialPrePaidTest < PlanChangeTimezones
      include NonTrialPrePaidSharedTests

      def billing_strategy_factory
        :prepaid_billing
      end

      setup do
        disable_instant_bill_plan_change
        @contract = create_contract(trial_period_expires_at: nil, variable_cost_paid_until: nil)
      end

      # Prepaid differences from postpaid:
      # - bill_plan_change uses upgrade-only logic for billed contracts (no refund on downgrade)
      # - For unbilled contracts: bills old plan for previous period, then upgrade
      # - Variable costs go to NEXT month's invoice in daily billing
      # - Uses "Application upgrade" line item instead of "Fixed fee" for new plan

      test 'plan change when in server TZ it is 1st but in UTC it is still 31st' do
        ENV['TZ'] = 'Asia/Shanghai'

        fake_hit(Time.utc(2025, 1, 1, 0, 1), 50, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 15, 12, 0), 100, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 30, 23, 59), 200, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 31, 12, 1), 400, @contract, @metric)
        fake_hit(Time.utc(2025, 2, 1, 0, 1), 800, @contract, @metric)

        travel_to Time.utc(2025, 1, 31, 23, 0)

        assert_equal 31, Time.now.utc.day
        assert_equal 1, Time.now.day # rubocop:disable Rails/TimeZone

        @contract.change_plan!(@premium_plan)
        travel_to(Time.utc(2025, 1, 31, 23, 30))

        invoices = @provider.buyer_invoices.reload
        assert_equal 1, invoices.count

        invoice = invoices.last
        assert_equal 1, invoice.period.begin.month, 'Invoice should be for January'

        # Prepaid unbilled: bills Basic for full January, then refund + upgrade for remaining period.
        # Uses "Application upgrade" instead of "Fixed fee" for the new plan.
        expected_jan_items = [
          [@basic_plan, "Fixed fee ('Basic')", "January  1, 2025 ( 0:00) - January 31, 2025 (23:59)", 10],
          [@basic_plan, "Refund ('Basic')", "January 31, 2025 (23:00) - January 31, 2025 (23:59)", -0.01],
          [@premium_plan, "Application upgrade ('Basic' to 'Premium')", "January 31, 2025 (23:00) - January 31, 2025 (23:59)", 0.07]
        ]
        assert_invoice_items invoice, expected_jan_items

        # Daily billing on Feb 1
        travel_to(Time.utc(2025, 2, 1, 0, 1))
        Finance::BillingStrategy.daily(only: [@provider.id], skip_notifications: true)

        # January invoice should be unchanged (finalized by prepaid)
        assert_invoice_items invoice, expected_jan_items

        # Prepaid: January variable costs go on FEBRUARY invoice.
        # BUG: all hits billed under Premium (current plan) instead of Basic.
        # Usage: 50+100+200+400 = 750 hits at $0.02 = $15
        invoices = @provider.buyer_invoices.reload.order(:period)
        feb_invoices = invoices.select { |i| i.period.begin.month == 2 }
        assert_not_empty feb_invoices, 'Should have a February invoice'
        invoice_feb = feb_invoices.last
        assert_invoice_items invoice_feb, [
          [@premium_plan, "Fixed fee ('Premium')", "February  1, 2025 ( 0:00) - February 28, 2025 (23:59)", 50],
          [@premium_plan, "Hits", "January  1, 2025 ( 0:00) - January 31, 2025 (23:59)", 15]
        ]
      end

      test 'plan change in UTC near end of month' do
        ENV['TZ'] = 'UTC'

        fake_hit(Time.utc(2025, 1, 1, 0, 1), 50, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 15, 12, 0), 100, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 30, 23, 59), 200, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 31, 12, 1), 400, @contract, @metric)
        fake_hit(Time.utc(2025, 2, 1, 0, 1), 800, @contract, @metric)

        travel_to(Time.utc(2025, 1, 31, 23, 0))
        @contract.change_plan!(@premium_plan)
        travel_to(Time.utc(2025, 1, 31, 23, 30))

        invoices = @provider.buyer_invoices.reload
        assert_equal 1, invoices.count

        invoice = invoices.last

        # Prepaid unbilled: same as test 1 for plan change items
        expected_jan_items = [
          [@basic_plan, "Fixed fee ('Basic')", "January  1, 2025 ( 0:00) - January 31, 2025 (23:59)", 10],
          [@basic_plan, "Refund ('Basic')", "January 31, 2025 (23:00) - January 31, 2025 (23:59)", -0.01],
          [@premium_plan, "Application upgrade ('Basic' to 'Premium')", "January 31, 2025 (23:00) - January 31, 2025 (23:59)", 0.07]
        ]
        assert_invoice_items invoice, expected_jan_items

        travel_to(Time.utc(2025, 2, 1, 0, 1))
        Finance::BillingStrategy.daily(only: [@provider.id], skip_notifications: true)

        # January invoice unchanged after daily billing
        assert_invoice_items invoice, expected_jan_items

        # Prepaid: January variable costs on February invoice
        # BUG: all hits under Premium instead of Basic
        invoices = @provider.buyer_invoices.reload.order(:period)
        feb_invoices = invoices.select { |i| i.period.begin.month == 2 }
        assert_not_empty feb_invoices
        invoice_feb = feb_invoices.last
        assert_invoice_items invoice_feb, [
          [@premium_plan, "Fixed fee ('Premium')", "February  1, 2025 ( 0:00) - February 28, 2025 (23:59)", 50],
          [@premium_plan, "Hits", "January  1, 2025 ( 0:00) - January 31, 2025 (23:59)", 15]
        ]
      end

      test 'plan change when in server TZ it is 31st but in UTC it is already 1st' do
        ENV['TZ'] = 'America/Los_Angeles'

        fake_hit(Time.utc(2025, 1, 1, 0, 1), 50, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 15, 12, 0), 100, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 30, 23, 59), 200, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 31, 12, 1), 400, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 31, 23, 59), 800, @contract, @metric)
        fake_hit(Time.utc(2025, 2, 1, 0, 1), 1600, @contract, @metric)

        # In UTC: Feb 1 01:00, In Pacific: Jan 31 17:00
        travel_to Time.utc(2025, 2, 1, 1, 0)

        @contract.change_plan!(@premium_plan)

        # Prepaid unbilled: previous_period spans Jan 1 to Feb 28 (cross-month!).
        # This triggers PeriodRangeCalculationError in cost_for_period.
        # Falls through to bill_plan_change_for_billed_contract which only bills the upgrade.
        # BUG: Refund of Basic for February even though Basic was never billed for February.
        # BUG: No fixed fee for January or February (lost due to cross-month error).
        invoices = @provider.buyer_invoices.to_a
        assert_equal 1, invoices.count

        invoice_feb = invoices.first
        assert_equal 2, invoice_feb.period.begin.month

        expected_feb_items = [
          [@basic_plan, "Refund ('Basic')", "February  1, 2025 ( 1:00) - February 28, 2025 (23:59)", -9.99],
          [@premium_plan, "Application upgrade ('Basic' to 'Premium')", "February  1, 2025 ( 1:00) - February 28, 2025 (23:59)", 49.93]
        ]
        assert_invoice_items invoice_feb, expected_feb_items

        travel_to Time.utc(2025, 2, 1, 12, 0)
        Finance::BillingStrategy.daily(only: [@provider.id], skip_notifications: true)

        # Prepaid daily: January variable costs go on February invoice.
        # BUG: all hits billed under Premium instead of Basic.
        # Usage: 50+100+200+400+800 = 1550 hits at $0.02 = $31
        invoices = @provider.buyer_invoices.reload.order(:period)

        # No January invoice expected (prepaid bills variable costs on next month's invoice)
        jan_invoices = invoices.select { |i| i.period.begin.month == 1 }
        assert_empty jan_invoices, 'Prepaid should not create a January invoice'

        # BUG: paid_until was set to Feb 28 by plan_changed, so bill_fixed_costs skips (Feb 28 < Feb 28 → false).
        # No Fixed fee for February is ever created.
        # Prepaid: January variable costs go on February invoice.
        assert_invoice_items invoice_feb.reload, expected_feb_items + [
          [@premium_plan, "Hits", "January  1, 2025 ( 0:00) - January 31, 2025 (23:59)", 31]
        ]

        travel_to Time.utc(2025, 3, 1, 12, 0)
        Finance::BillingStrategy.daily(only: [@provider.id], skip_notifications: true)

        # February variable costs go on March invoice
        invoices = @provider.buyer_invoices.reload.order(:period)
        mar_invoices = invoices.select { |i| i.period.begin.month == 3 }
        assert_not_empty mar_invoices
        invoice_mar = mar_invoices.last
        assert_invoice_items invoice_mar, [
          [@premium_plan, "Fixed fee ('Premium')", "March  1, 2025 ( 0:00) - March 31, 2025 (23:59)", 50],
          [@premium_plan, "Hits", "February  1, 2025 ( 0:00) - February 28, 2025 (23:59)", 32]
        ]
      end

      test "2 plan changes during a month billing with UTC (the only supported TZ)" do
        ENV['TZ'] = 'UTC'

        max_plan = FactoryBot.create(:application_plan, issuer: @service, name: 'Max', cost_per_month: 100)
        max_plan.pricing_rules.create!(metric: @metric, cost_per_unit: 0.04)

        fake_hit(Time.utc(2025, 1, 1, 0, 0), 25, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 6, 23, 59), 50, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 7, 12, 0), 100, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 14, 23, 59), 200, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 15, 12, 0), 400, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 31, 23, 59), 800, @contract, @metric)
        fake_hit(Time.utc(2025, 2, 1, 0, 1), 1600, @contract, @metric)

        travel_to Time.utc(2025, 1, 7, 12, 0)
        @contract.change_plan!(@premium_plan)
        # First plan change: prepaid unbilled → Fixed fee Basic $10, Refund Basic, Upgrade B→P

        travel_to Time.utc(2025, 1, 15, 12, 0)
        @contract.change_plan!(max_plan)
        assert_equal 1, @provider.buyer_invoices.count
        # Second plan change: prepaid billed (paid_until set by first plan_changed)
        # Only upgrade: Refund Premium, Upgrade P→M

        travel_to Time.utc(2025, 2, 1, 0, 1)
        Finance::BillingStrategy.daily(only: [@provider.id], skip_notifications: true)
        invoices = @provider.buyer_invoices.reload.to_a
        assert_operator invoices.count, :>=, 2

        invoice_jan = invoices.first

        # No variable costs at plan change (instant off).
        # All variable costs billed during daily billing under current plan (Max).
        # BUG: all hits billed at Max rate ($0.04) instead of each plan's rate.
        # Usage: 25+50+100+200+400+800 = 1575 hits, 1575 * 0.04 = $63
        assert_invoice_items invoice_jan, [
          [@basic_plan, "Fixed fee ('Basic')", "January  1, 2025 ( 0:00) - January 31, 2025 (23:59)", 10],
          [@basic_plan, "Refund ('Basic')", "January  7, 2025 (12:00) - January 31, 2025 (23:59)", -7.9],
          [@premium_plan, "Application upgrade ('Basic' to 'Premium')", "January  7, 2025 (12:00) - January 31, 2025 (23:59)", 39.52],
          [@premium_plan, "Refund ('Premium')", "January 15, 2025 (12:00) - January 31, 2025 (23:59)", -26.61],
          [max_plan, "Application upgrade ('Premium' to 'Max')", "January 15, 2025 (12:00) - January 31, 2025 (23:59)", 53.23]
        ]

        # Prepaid: January variable costs go on February invoice
        invoice_feb = invoices.find { |i| i.period.begin.month == 2 }
        assert_not_nil invoice_feb
        assert_invoice_items invoice_feb, [
          [max_plan, "Fixed fee ('Max')", "February  1, 2025 ( 0:00) - February 28, 2025 (23:59)", 100],
          [max_plan, "Hits", "January  1, 2025 ( 0:00) - January 31, 2025 (23:59)", 63]
        ]
      end
    end

    class NonTrialPrePaidInstantTest < PlanChangeTimezones
      include NonTrialPrePaidSharedTests

      def billing_strategy_factory
        :prepaid_billing
      end

      setup do
        enable_instant_bill_plan_change
        @contract = create_contract(trial_period_expires_at: nil, variable_cost_paid_until: nil)
      end

      # Prepaid + instant: bill_variable_for_plan_changed bills variable costs at plan change time
      # (same as postpaid instant), but plan_changed uses prepaid bill_plan_change logic.

      test 'plan change when in server TZ it is 1st but in UTC it is still 31st' do
        ENV['TZ'] = 'Asia/Shanghai'

        fake_hit(Time.utc(2025, 1, 1, 0, 1), 50, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 15, 12, 0), 100, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 30, 23, 59), 200, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 31, 12, 1), 400, @contract, @metric)
        fake_hit(Time.utc(2025, 2, 1, 0, 1), 800, @contract, @metric)

        # In UTC: Jan 31 23:00 (still January, day 31)
        # In Shanghai: Feb 1 07:00 (already February, day 1)
        travel_to Time.utc(2025, 1, 31, 23, 0)

        assert_equal 31, Time.now.utc.day
        assert_equal 1, Time.now.day # rubocop:disable Rails/TimeZone

        @contract.change_plan!(@premium_plan)

        # Travel after last recorded usage for consistency, still 31st
        travel_to(Time.utc(2025, 1, 31, 23, 30))

        invoices = @provider.buyer_invoices.reload
        assert_equal 1, invoices.count

        invoice = invoices.last
        assert_equal 1, invoice.period.end.month

        # #bill_variable_for_plan_changed uses Time.now (Shanghai = Feb 1).
        # Month.new(Time.now) = February → billing period is empty on 1st of month.
        # So no variable cost billing at plan change (same as postpaid instant with Shanghai TZ).
        # Prepaid unbilled: Fixed fee Basic, Refund Basic, Upgrade.
        expected_jan_items = [
          [@basic_plan, "Fixed fee ('Basic')", "January  1, 2025 ( 0:00) - January 31, 2025 (23:59)", 10],
          [@basic_plan, "Refund ('Basic')", "January 31, 2025 (23:00) - January 31, 2025 (23:59)", -0.01],
          [@premium_plan, "Application upgrade ('Basic' to 'Premium')", "January 31, 2025 (23:00) - January 31, 2025 (23:59)", 0.07]
        ]
        assert_invoice_items invoice, expected_jan_items

        # Now travel to Feb 1 to check final billing
        travel_to(Time.utc(2025, 2, 1, 0, 1))
        Finance::BillingStrategy.daily(only: [@provider.id], skip_notifications: true)

        # January invoice unchanged
        assert_invoice_items invoice, expected_jan_items

        # Prepaid: January variable costs on February invoice
        # BUG: all hits under Premium instead of Basic
        invoices = @provider.buyer_invoices.reload.order(:period)
        feb_invoices = invoices.select { |i| i.period.begin.month == 2 }
        assert_not_empty feb_invoices
        invoice_feb = feb_invoices.last
        assert_invoice_items invoice_feb, [
          [@premium_plan, "Fixed fee ('Premium')", "February  1, 2025 ( 0:00) - February 28, 2025 (23:59)", 50],
          [@premium_plan, "Hits", "January  1, 2025 ( 0:00) - January 31, 2025 (23:59)", 15]
        ]
        assert invoice_feb.finalized?
      end

      test 'plan change in UTC near end of month' do
        ENV['TZ'] = 'UTC'

        fake_hit(Time.utc(2025, 1, 1, 0, 1), 50, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 15, 12, 0), 100, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 30, 23, 59), 200, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 31, 12, 1), 400, @contract, @metric)
        fake_hit(Time.utc(2025, 2, 1, 0, 1), 800, @contract, @metric)

        travel_to(Time.utc(2025, 1, 31, 23, 0))
        @contract.change_plan!(@premium_plan)
        travel_to(Time.utc(2025, 1, 31, 23, 30))

        invoices = @provider.buyer_invoices.reload
        assert_equal 1, invoices.count

        invoice = invoices.last
        assert_equal 1, invoice.period.end.month

        # Instant: bill_variable_for_plan_changed bills Jan 1 - Jan 30 under Basic.
        # Prepaid unbilled: Fixed fee Basic, Refund Basic, Upgrade.
        # BUG: Jan 31 variable cost is never billed (variable_cost_paid_until = Jan 31 00:00,
        # daily billing checks Jan 31 < Jan 31 → false → skip)
        expected_jan_items = [
          [@basic_plan, "Hits", "January  1, 2025 ( 0:00) - January 30, 2025 (23:59)", 3.5],
          [@basic_plan, "Fixed fee ('Basic')", "January  1, 2025 ( 0:00) - January 31, 2025 (23:59)", 10],
          [@basic_plan, "Refund ('Basic')", "January 31, 2025 (23:00) - January 31, 2025 (23:59)", -0.01],
          [@premium_plan, "Application upgrade ('Basic' to 'Premium')", "January 31, 2025 (23:00) - January 31, 2025 (23:59)", 0.07]
        ]
        assert_invoice_items invoice, expected_jan_items

        # Now travel to Feb 1 to check final billing
        travel_to(Time.utc(2025, 2, 1, 0, 1))
        Finance::BillingStrategy.daily(only: [@provider.id], skip_notifications: true)
        assert invoice.reload.finalized?

        # BUG: Jan 31 variable cost lost (same as postpaid instant).
        # January invoice unchanged after daily billing.
        assert_invoice_items invoice, expected_jan_items

        # Prepaid: February invoice gets fixed fee only (no Jan variable costs since already billed)
        invoices = @provider.buyer_invoices.reload.order(:period)
        feb_invoices = invoices.select { |i| i.period.begin.month == 2 }
        assert_not_empty feb_invoices
        invoice_feb = feb_invoices.last
        assert_invoice_items invoice_feb, [
          [@premium_plan, "Fixed fee ('Premium')", "February  1, 2025 ( 0:00) - February 28, 2025 (23:59)", 50]
        ]
        assert invoice_feb.finalized?
      end

      test 'plan change when in server TZ it is 31st but in UTC it is already 1st' do
        ENV['TZ'] = 'America/Los_Angeles'

        fake_hit(Time.utc(2025, 1, 1, 0, 1), 50, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 15, 12, 0), 100, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 30, 23, 59), 200, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 31, 12, 1), 400, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 31, 23, 59), 800, @contract, @metric)
        fake_hit(Time.utc(2025, 2, 1, 0, 1), 1600, @contract, @metric)

        # In UTC: Feb 1 01:00, In Pacific: Jan 31 17:00
        travel_to Time.utc(2025, 2, 1, 1, 0)

        @contract.change_plan!(@premium_plan)

        # Instant: bill_variable_for_plan_changed uses Time.now (Pacific = Jan 31 17:00).
        # Month.new(Time.now) = January. period_from = max(Jan 1, Jan 1) = Jan 1.
        # last_midnight = Jan 31 00:00 Pacific = Jan 31 08:00 UTC.
        # Bills Jan 1 - Jan 30 under Basic on January invoice.
        #
        # plan_changed uses Time.now.utc (Feb 1 01:00) → February period.
        # Prepaid unbilled → cross-month PeriodRangeCalculationError → falls through to billed path.
        invoices = @provider.buyer_invoices.reload.order(:period)
        assert_equal 2, invoices.count

        invoice_jan = invoices.first
        invoice_feb = invoices.last

        # January invoice: instant variable cost only
        assert_invoice_items invoice_jan, [
          [@basic_plan, "Hits", "January  1, 2025 ( 0:00) - January 30, 2025 (23:59)", 3.5]
        ]

        # February invoice: upgrade items (no full-month fixed fee due to cross-month error),
        #   might be just because we didn't run billing in beginning of Jan or when contract was created
        expected_feb_items = [
          [@basic_plan, "Refund ('Basic')", "February  1, 2025 ( 1:00) - February 28, 2025 (23:59)", -9.99],
          [@premium_plan, "Application upgrade ('Basic' to 'Premium')", "February  1, 2025 ( 1:00) - February 28, 2025 (23:59)", 49.93]
        ]
        assert_invoice_items invoice_feb, expected_feb_items

        travel_to Time.utc(2025, 2, 1, 12, 0)
        Finance::BillingStrategy.daily(only: [@provider.id], skip_notifications: true)

        assert invoice_jan.reload.finalized?

        # Prepaid: remaining January variable costs (Jan 31) on February invoice.
        # variable_cost_paid_until was set to Jan 31 00:00 Pacific = Jan 31 08:00 UTC by instant billing.
        # Daily billing: should_bill? checks variable_cost_paid_until vs January period end.
        invoices = @provider.buyer_invoices.reload.order(:period)
        invoice_feb = invoices[1]
        assert_not_nil invoice_feb

        # BUG: paid_until was set to Feb 28 by plan_changed, so bill_fixed_costs skips.
        # BUG: instant billing set variable_cost_paid_until to Jan 31 (via Date.today in Pacific = Jan 31),
        # so daily billing's should_bill_variable_cost? checks Jan 31 < Jan 31 → false, skips variable costs.
        # January variable costs are lost entirely.
        assert_invoice_items invoice_feb, expected_feb_items

        travel_to Time.utc(2025, 3, 1, 12, 0)
        Finance::BillingStrategy.daily(only: [@provider.id], skip_notifications: true)

        invoices = @provider.buyer_invoices.reload.order(:period)
        invoice_mar = invoices.select { |i| i.period.begin.month == 3 }.last
        assert_not_nil invoice_mar
        assert_invoice_items invoice_mar, [
          [@premium_plan, "Fixed fee ('Premium')", "March  1, 2025 ( 0:00) - March 31, 2025 (23:59)", 50],
          [@premium_plan, "Hits", "February  1, 2025 ( 0:00) - February 28, 2025 (23:59)", 32]
        ]
      end

      test "2 plan changes during a month billing with UTC (the only supported TZ)" do
        ENV['TZ'] = 'UTC'

        max_plan = FactoryBot.create(:application_plan, issuer: @service, name: 'Max', cost_per_month: 100)
        max_plan.pricing_rules.create!(metric: @metric, cost_per_unit: 0.04)

        fake_hit(Time.utc(2025, 1, 1, 0, 0), 25, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 6, 23, 59), 50, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 7, 12, 0), 100, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 14, 23, 59), 200, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 15, 12, 0), 400, @contract, @metric)
        fake_hit(Time.utc(2025, 1, 31, 23, 59), 800, @contract, @metric)
        fake_hit(Time.utc(2025, 2, 1, 0, 1), 1600, @contract, @metric)

        travel_to Time.utc(2025, 1, 7, 12, 0)
        @contract.change_plan!(@premium_plan)
        # Instant: bills Jan 1 - Jan 6 under Basic. Prepaid unbilled: Fixed fee Basic, Refund, Upgrade.

        travel_to Time.utc(2025, 1, 15, 12, 0)
        @contract.change_plan!(max_plan)
        assert_equal 1, @provider.buyer_invoices.count
        # Instant: bills Jan 7 - Jan 14 under Premium. Prepaid billed: Refund Premium, Upgrade P→M.

        travel_to Time.utc(2025, 2, 1, 0, 1)
        Finance::BillingStrategy.daily(only: [@provider.id], skip_notifications: true)
        invoices = @provider.buyer_invoices.reload.to_a
        assert_operator invoices.count, :>=, 2

        invoice_jan = invoices.first
        invoice_feb = invoices.last
        assert invoice_jan.finalized?
        assert invoice_feb.finalized?

        # Instant variable costs at each plan change + prepaid fixed fee items.
        # Max Hits (Jan 15-31) not billed instantly — they go on Feb invoice via daily billing.
        assert_invoice_items invoice_jan, [
          [@basic_plan, "Hits", "January  1, 2025 ( 0:00) - January  6, 2025 (23:59)", 0.75],
          [@basic_plan, "Fixed fee ('Basic')", "January  1, 2025 ( 0:00) - January 31, 2025 (23:59)", 10],
          [@basic_plan, "Refund ('Basic')", "January  7, 2025 (12:00) - January 31, 2025 (23:59)", -7.9],
          [@premium_plan, "Application upgrade ('Basic' to 'Premium')", "January  7, 2025 (12:00) - January 31, 2025 (23:59)", 39.52],
          [@premium_plan, "Hits", "January  7, 2025 ( 0:00) - January 14, 2025 (23:59)", 6],
          [@premium_plan, "Refund ('Premium')", "January 15, 2025 (12:00) - January 31, 2025 (23:59)", -26.61],
          [max_plan, "Application upgrade ('Premium' to 'Max')", "January 15, 2025 (12:00) - January 31, 2025 (23:59)", 53.23]
        ]

        # Prepaid: remaining January variable costs (Jan 15-31 under Max) go on February invoice
        assert_not_nil invoice_feb
        assert_invoice_items invoice_feb, [
          [max_plan, "Fixed fee ('Max')", "February  1, 2025 ( 0:00) - February 28, 2025 (23:59)", 100],
          [max_plan, "Hits", "January 15, 2025 ( 0:00) - January 31, 2025 (23:59)", 48]
        ]
      end
    end
  end
end
