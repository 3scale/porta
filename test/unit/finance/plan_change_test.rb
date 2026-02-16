# frozen_string_literal: true

require 'test_helper'

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

  class PlanChangeTimezoneTest < ActiveSupport::TestCase
    # include BillingResultsTestHelpers
    include TestHelpers::FakeHits

    setup do
      @original_tz = ENV.fetch('TZ', nil)
      @storage = Stats::Base.storage
      @storage.flushdb

      provider_created_at = Time.zone.local(1983, 11, 1)
      @provider = FactoryBot.create(:provider_with_billing, created_at: provider_created_at, timezone: 'Pacific Time (US & Canada)')
      @provider.billing_strategy.update!(charging_enabled: true)

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

    # === Non-trial plan change tests ===

    # This test demonstrates the timezone discrepancy between BillingObserver#bill_variable_for_plan_changed
    # (uses server TZ via Time.now/Date.today) and BillingObserver#plan_changed (uses UTC via Time.now.utc).
    test 'plan change when in server TZ it is 1st but in UTC it is still 31st' do
      # Set server timezone to Shanghai (UTC+8)
      ENV['TZ'] = 'Asia/Shanghai'

      contract = create_contract(trial_period_expires_at: nil, variable_cost_paid_until: nil)

      # Create usage in January UTC
      fake_hit(Time.utc(2025, 1, 1, 0, 1), 50, contract, @metric)
      fake_hit(Time.utc(2025, 1, 15, 12, 0), 100, contract, @metric)
      fake_hit(Time.utc(2025, 1, 30, 23, 59), 200, contract, @metric)
      fake_hit(Time.utc(2025, 1, 31, 12, 1), 400, contract, @metric)
      fake_hit(Time.utc(2025, 2, 1, 0, 1), 800, contract, @metric)

      # In UTC: Jan 31 23:00 (still January, day 31)
      # In Shanghai: Feb 1 07:00 (already February, day 1)
      travel_to Time.utc(2025, 1, 31, 23, 0)

      # Verify the timezone discrepancy
      assert_equal 31, Time.now.utc.day, 'UTC should be on the 31st'
      assert_equal 1, Time.now.day, 'Server local time (Shanghai) should be on the 1st' # rubocop:disable Rails/TimeZone

      # Change plan from basic to premium
      # This triggers both bill_variable_for_plan_changed and plan_changed
      contract.change_plan!(@premium_plan)

      # Travel after last recorded usage for consistency, still 31st
      travel_to(Time.utc(2025, 1, 31, 23, 30))

      # Check invoices to see the actual behavior
      invoices = @provider.buyer_invoices.reload
      assert_equal 1, invoices.count, 'Should have created an invoice for January and items'

      # This test documents the current behavior, while it is possibly undesirable
      invoice = invoices.last
      assert_equal 3, invoice.line_items.count, 'Expected to created an invoice with 3 items'
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
      items = invoice.line_items.to_a
      assert_equal @basic_plan.id, items[0].plan_id
      assert_equal "Fixed fee ('Basic')", items[0].name
      assert_equal "January  1, 2025 ( 0:00) - January 31, 2025 (23:59)", items[0].description

      assert_equal @basic_plan.id, items[1].plan_id
      assert_equal "Refund ('Basic')", items[1].name
      assert_equal "January 31, 2025 (23:00) - January 31, 2025 (23:59)", items[1].description

      assert_equal @premium_plan.id, items[2].plan_id
      assert_equal "Fixed fee ('Premium')", items[2].name
      assert_equal "January 31, 2025 (23:00) - January 31, 2025 (23:59)", items[2].description

      # Now travel to Feb 1 to check final billing
      travel_to(Time.utc(2025, 2, 1, 0, 1))
      Finance::BillingStrategy.daily(only: [@provider.id], skip_notifications: true)
      final_items = invoice.line_items.reload.to_a

      assert_equal items, final_items[0..2]
      # This seems like a BUG: all hits attributed to Premium plan, instead of just for the last day
      assert_equal @premium_plan.id, final_items[3].plan_id
      assert_equal "Hits", final_items[3].name
      assert_equal "January  1, 2025 ( 0:00) - January 31, 2025 (23:59)", final_items[3].description
      assert_equal 750, final_items[3].quantity
    end

    test 'plan change at UTC month boundary bills consistently variable and fixed cost' do
      # Keep server in UTC which is the only supported configuration
      ENV['TZ'] = 'UTC'

      contract = create_contract(trial_period_expires_at: nil, variable_cost_paid_until: nil)

      # Create usage in January UTC
      fake_hit(Time.utc(2025, 1, 1, 0, 1), 50, contract, @metric)
      fake_hit(Time.utc(2025, 1, 15, 12, 0), 100, contract, @metric)
      fake_hit(Time.utc(2025, 1, 30, 23, 59), 200, contract, @metric)
      fake_hit(Time.utc(2025, 1, 31, 12, 1), 400, contract, @metric)
      fake_hit(Time.utc(2025, 2, 1, 0, 1), 800, contract, @metric)

      # Travel to just before UTC month end
      travel_to(Time.utc(2025, 1, 31, 23, 0))

      # Change plan
      contract.change_plan!(@premium_plan)

      # Travel after last recorded usage for consistency, still 31st
      travel_to(Time.utc(2025, 1, 31, 23, 30))

      invoices = @provider.buyer_invoices.reload
      assert_equal 1, invoices.count, 'Should have created an invoice for January and items'

      invoice = invoices.last
      assert_equal 4, invoice.line_items.count, 'Should have created an invoice with 4 items'
      assert_equal 1, invoice.period.begin.day, 'Invoice should be for January (starting day 1)'
      assert_equal 31, invoice.period.end.day, 'Invoice should be for January (ending day 31)'

      items = invoice.line_items.to_a

      assert_equal @basic_plan.id, items[0].plan_id
      assert_equal @metric.id, items[0].metric_id
      assert_equal 350, items[0].quantity
      assert_equal "January  1, 2025 ( 0:00) - January 30, 2025 (23:59)", items[0].description

      assert_equal @basic_plan.id, items[1].plan_id
      assert_equal "Fixed fee ('Basic')", items[1].name
      assert_equal "January  1, 2025 ( 0:00) - January 31, 2025 (23:59)", items[1].description
      assert_equal 10, items[1].cost

      # it looks like that we bill variable cost for the full day when plan is changed
      # but fixed cost appears prorated based on the plan change time of the day
      # is this a BUG?
      assert_equal @basic_plan.id, items[2].plan_id
      assert_equal "Refund ('Basic')", items[2].name
      assert_equal "January 31, 2025 (23:00) - January 31, 2025 (23:59)", items[2].description
      assert_equal(-0.01, items[2].cost) # just an hour refund of Basic plan

      assert_equal @premium_plan.id, items[3].plan_id
      assert_equal "Fixed fee ('Premium')", items[3].name
      assert_equal "January 31, 2025 (23:00) - January 31, 2025 (23:59)", items[3].description
      assert_equal 0.07, items[3].cost # Just the cost of an hour in the Premium plan

      # Now travel to Feb 1 to check final billing
      travel_to(Time.utc(2025, 2, 1, 0, 1))
      Finance::BillingStrategy.daily(only: [@provider.id], skip_notifications: true)
      assert invoice.reload.finalized?

      final_items = invoice.line_items.reload.to_a
      assert_equal items, final_items[0..3]
      # Looks like a BUG: apparently we didn't add any lines for variable cost after plan change
      # assert_equal @premium_plan.id, final_items[4].plan_id
      # assert_equal "Hits", final_items[4].name
      # assert_equal "January  31, 2025 ( 0:00) - January 31, 2025 (23:59)", final_items[4].description
      # assert_equal 400, final_items[4].quantity
      assert_nil final_items[4]
    end

    test 'plan change when in server TZ it is 31st but in UTC it is already 1st' do
      # Set server timezone to Pacific (UTC-8)
      ENV['TZ'] = 'America/Los_Angeles'

      contract = create_contract(trial_period_expires_at: nil, variable_cost_paid_until: nil)

      fake_hit(Time.utc(2025, 1, 1, 0, 1), 50, contract, @metric)
      fake_hit(Time.utc(2025, 1, 15, 12, 0), 100, contract, @metric)
      fake_hit(Time.utc(2025, 1, 30, 23, 59), 200, contract, @metric)
      fake_hit(Time.utc(2025, 1, 31, 12, 1), 400, contract, @metric)
      fake_hit(Time.utc(2025, 1, 31, 23, 59), 800, contract, @metric)
      fake_hit(Time.utc(2025, 2, 1, 0, 1), 1600, contract, @metric)

      # In UTC: Feb 1 01:00 (already February, day 1)
      # In Pacific: Jan 31 17:0 (still January, day 31)
      travel_to Time.utc(2025, 2, 1, 1, 0)

      contract.change_plan!(@premium_plan)

      invoices = @provider.buyer_invoices.to_a
      assert_equal 2, invoices.count

      invoice_jan = invoices.first
      invoice_feb = invoices.last

      items_jan = invoice_jan.line_items.to_a
      items_feb = invoice_feb.line_items.to_a

      assert_equal 1, items_jan.count, 'Expected 1 item in Jan invoice but more important is final billing'
      assert_equal 3, items_feb.count, 'Expected 2 items in Jan invoice but more important is final billing'

      assert_equal @basic_plan.id, items_jan[0].plan_id
      assert_equal "Hits", items_jan[0].name
      assert_equal "January  1, 2025 ( 0:00) - January 30, 2025 (23:59)", items_jan[0].description
      assert_equal 350, items_jan[0].quantity

      assert_equal @basic_plan.id, items_feb[0].plan_id
      assert_equal "Fixed fee ('Basic')", items_feb[0].name
      assert_equal "February  1, 2025 ( 0:00) - February 28, 2025 (23:59)", items_feb[0].description
      assert_equal 10, items_feb[0].cost

      # it looks like that we bill variable cost for the full day when plan is changed
      # but fixed cost appears prorated based on the plan change time of the day
      # is this a BUG?
      assert_equal @basic_plan.id, items_feb[1].plan_id
      assert_equal "Refund ('Basic')", items_feb[1].name
      assert_equal "February  1, 2025 ( 1:00) - February 28, 2025 (23:59)", items_feb[1].description
      assert_equal(-9.99, items_feb[1].cost)

      assert_equal @premium_plan.id, items_feb[2].plan_id
      assert_equal "Fixed fee ('Premium')", items_feb[2].name
      assert_equal "February  1, 2025 ( 1:00) - February 28, 2025 (23:59)", items_feb[2].description
      assert_equal 49.93, items_feb[2].cost

      travel_to Time.utc(2025, 2, 1, 12, 0)
      Finance::BillingStrategy.daily(only: [@provider.id], skip_notifications: true)
      final_items_jan = invoice_jan.line_items.reload.to_a
      final_items_feb = invoice_feb.line_items.reload.to_a

      assert invoice_jan.reload.finalized?
      # looks like a BUG: no fixes cost billed for Jan after Feb final billing
      # maybe if billing was performed at the begining of jan, that would be avoided,
      # but what if buyer was created mid-month?
      assert_equal items_jan, final_items_jan
      assert_not invoice_feb.reload.finalized?
      assert_equal items_feb, final_items_feb, "Invoice for Feb should not have been touched"

      travel_to Time.utc(2025, 3, 1, 12, 0)
      Finance::BillingStrategy.daily(only: [@provider.id], skip_notifications: true)
      assert invoice_feb.reload.finalized?

      very_final_items_jan = invoice_jan.line_items.reload.to_a
      very_final_items_feb = invoice_feb.line_items.reload.to_a

      assert_equal items_jan, very_final_items_jan # not fixed but expected at this point
      assert_equal items_feb, very_final_items_feb[0..2]

      assert_equal @premium_plan.id, very_final_items_feb[3].plan_id
      assert_equal "Hits", very_final_items_feb[3].name
      assert_equal "February  1, 2025 ( 0:00) - February 28, 2025 (23:59)", very_final_items_feb[3].description
      assert_equal 32, very_final_items_feb[3].cost # This must be a strange BUG, plan cost is 50
    end

    test "2 plan changes during a month billing with UTC (the only supported TZ)" do
      # Keep server in UTC which is the only supported configuration
      ENV['TZ'] = 'UTC'

      max_plan = FactoryBot.create(:application_plan, issuer: @service, name: 'Max', cost_per_month: 100)
      max_plan.pricing_rules.create!(metric: @metric, cost_per_unit: 0.04)

      contract = create_contract(trial_period_expires_at: nil, variable_cost_paid_until: nil)

      fake_hit(Time.utc(2025, 1, 1, 0, 0), 25, contract, @metric)
      fake_hit(Time.utc(2025, 1, 6, 23, 59), 50, contract, @metric)
      fake_hit(Time.utc(2025, 1, 7, 12, 0), 100, contract, @metric)
      fake_hit(Time.utc(2025, 1, 14, 23, 59), 200, contract, @metric)
      fake_hit(Time.utc(2025, 1, 15, 12, 0), 400, contract, @metric)
      fake_hit(Time.utc(2025, 1, 31, 23, 59), 800, contract, @metric)
      fake_hit(Time.utc(2025, 2, 1, 0, 1), 1600, contract, @metric)

      travel_to Time.utc(2025, 1, 7, 12, 0)
      contract.change_plan!(@premium_plan)
      # we don't care what happens mid-cycle, only the final invoice matters

      travel_to Time.utc(2025, 1, 15, 12, 0)
      contract.change_plan!(max_plan)
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

      final_items_jan = invoice_jan.line_items.to_a
      assert_equal 8, final_items_jan.count

      assert_equal @basic_plan.id, final_items_jan[0].plan_id
      assert_equal "Hits", final_items_jan[0].name
      assert_equal "January  1, 2025 ( 0:00) - January  6, 2025 (23:59)", final_items_jan[0].description
      assert_equal 75, final_items_jan[0].quantity

      assert_equal @basic_plan.id, final_items_jan[1].plan_id
      assert_equal "Fixed fee ('Basic')", final_items_jan[1].name
      assert_equal "January  1, 2025 ( 0:00) - January 31, 2025 (23:59)", final_items_jan[1].description
      assert_equal 10, final_items_jan[1].cost

      assert_equal @basic_plan.id, final_items_jan[2].plan_id
      assert_equal "Refund ('Basic')", final_items_jan[2].name
      assert_equal "January  7, 2025 (12:00) - January 31, 2025 (23:59)", final_items_jan[2].description
      assert_equal(-7.9, final_items_jan[2].cost)

      assert_equal @premium_plan.id, final_items_jan[3].plan_id
      assert_equal "Fixed fee ('Premium')", final_items_jan[3].name
      assert_equal "January  7, 2025 (12:00) - January 31, 2025 (23:59)", final_items_jan[3].description
      assert_equal 39.52, final_items_jan[3].cost

      assert_equal @premium_plan.id, final_items_jan[4].plan_id
      assert_equal "Hits", final_items_jan[4].name
      assert_equal "January  7, 2025 ( 0:00) - January 14, 2025 (23:59)", final_items_jan[4].description
      assert_equal 300, final_items_jan[4].quantity

      assert_equal @premium_plan.id, final_items_jan[5].plan_id
      assert_equal "Refund ('Premium')", final_items_jan[5].name
      assert_equal "January 15, 2025 (12:00) - January 31, 2025 (23:59)", final_items_jan[5].description
      assert_equal(-26.61, final_items_jan[5].cost)

      assert_equal max_plan.id, final_items_jan[6].plan_id
      assert_equal "Fixed fee ('Max')", final_items_jan[6].name
      assert_equal "January 15, 2025 (12:00) - January 31, 2025 (23:59)", final_items_jan[6].description
      assert_equal 53.23, final_items_jan[6].cost

      assert_equal max_plan.id, final_items_jan[7].plan_id
      assert_equal "Hits", final_items_jan[7].name
      assert_equal "January 15, 2025 ( 0:00) - January 31, 2025 (23:59)", final_items_jan[7].description
      assert_equal 1200, final_items_jan[7].quantity
    end

    # TODO: we may want to test some of these scenarios in post-paid mode too, mainly the double change test

    # === Trial period plan change tests ===

    # test 'plan change within trial period does not bill' do
    #   ENV['TZ'] = 'UTC'
    #
    #   # Create contract with trial ending Jan 31
    #   trial_end = Time.utc(2025, 1, 31, 23, 59, 59)
    #   contract = create_contract(trial_period_expires_at: trial_end)
    #
    #   # Create usage
    #   fake_hit(Time.utc(2025, 1, 15, 12, 0), 100, contract, @metric)
    #
    #   # Change plan on Jan 20 - still within trial
    #   travel_to(Time.utc(2025, 1, 20, 12, 0))
    #
    #   assert contract.trial?, 'Contract should be in trial period'
    #
    #   contract.change_plan!(@premium_plan)
    #
    #   # No billing should occur during trial
    #   invoices = @provider.buyer_invoices.reload
    #   assert_empty invoices, 'Should not bill during trial period'
    # end
    #
    # test 'plan change after trial period expires does bill' do
    #   ENV['TZ'] = 'UTC'
    #
    #   # Create contract with trial ending Jan 15
    #   trial_end = Time.utc(2025, 1, 15, 23, 59, 59)
    #   contract = create_contract(trial_period_expires_at: trial_end, variable_cost_paid_until: nil)
    #
    #   # Create usage after trial ends
    #   fake_hit(Time.utc(2025, 1, 20, 12, 0), 100, contract, @metric)
    #
    #   # Change plan on Jan 25 - after trial
    #   travel_to(Time.utc(2025, 1, 25, 12, 0))
    #
    #   assert_not contract.trial?, 'Contract should NOT be in trial period'
    #
    #   contract.change_plan!(@premium_plan)
    #
    #   # Billing should occur after trial
    #   invoices = @provider.buyer_invoices.reload
    #   assert_not_empty invoices, 'Should bill after trial period expires'
    # end
    #
    # # Test TZ/UTC boundary: trial ends at a time that is different day in UTC vs local
    # test 'plan change at trial end TZ boundary - UTC before trial end but local after' do
    #   # Server timezone Shanghai (UTC+8)
    #   ENV['TZ'] = 'Asia/Shanghai'
    #
    #   # Trial ends Jan 15 23:59:59 UTC = Jan 16 07:59:59 Shanghai
    #   trial_end = Time.utc(2025, 1, 15, 23, 59, 59)
    #   contract = create_contract(trial_period_expires_at: trial_end, variable_cost_paid_until: nil)
    #
    #   fake_hit(Time.utc(2025, 1, 14, 12, 0), 100, contract, @metric)
    #
    #   # Travel to Jan 15 20:00 UTC = Jan 16 04:00 Shanghai
    #   # In UTC: still Jan 15, before trial end (Jan 15 23:59:59)
    #   # In Shanghai: already Jan 16, after trial end would appear to be over
    #   travel_to(Time.utc(2025, 1, 15, 20, 0))
    #
    #   # Verify timezone discrepancy
    #   assert_equal 15, Time.now.utc.day, 'UTC should be on the 15th'
    #   assert_equal 16, Time.now.day, 'Server local time should be on the 16th' # rubocop:disable Rails/TimeZone
    #
    #   # contract.trial? uses Time.now.utc, so it should still be in trial
    #   # This documents the current behavior
    #   is_in_trial = contract.trial?
    #
    #   contract.change_plan!(@premium_plan)
    #
    #   invoices = @provider.buyer_invoices.reload
    #
    #   if is_in_trial
    #     assert_empty invoices, 'Should NOT bill because UTC time is before trial end'
    #   else
    #     assert_not_empty invoices, 'Should bill because trial check uses local time'
    #   end
    # end
    #
    # # Test TZ/UTC boundary: trial ends at a time that is different day in UTC vs local (opposite direction)
    # test 'plan change at trial end TZ boundary - UTC after trial end but local before' do
    #   # Server timezone Pacific (UTC-8)
    #   ENV['TZ'] = 'America/Los_Angeles'
    #
    #   # Trial ends Jan 15 04:00:00 UTC = Jan 14 20:00:00 Pacific
    #   trial_end = Time.utc(2025, 1, 15, 4, 0, 0)
    #   contract = create_contract(trial_period_expires_at: trial_end, variable_cost_paid_until: nil)
    #
    #   fake_hit(Time.utc(2025, 1, 14, 12, 0), 100, contract, @metric)
    #
    #   # Travel to Jan 15 06:00 UTC = Jan 14 22:00 Pacific
    #   # In UTC: Jan 15, after trial end (Jan 15 04:00:00)
    #   # In Pacific: still Jan 14, before trial end would appear
    #   travel_to(Time.utc(2025, 1, 15, 6, 0))
    #
    #   # Verify timezone discrepancy
    #   assert_equal 15, Time.now.utc.day, 'UTC should be on the 15th'
    #   assert_equal 14, Time.now.day, 'Server local time should be on the 14th' # rubocop:disable Rails/TimeZone
    #
    #   # contract.trial? uses Time.now.utc, so trial should be over
    #   is_in_trial = contract.trial?
    #
    #   contract.change_plan!(@premium_plan)
    #
    #   invoices = @provider.buyer_invoices.reload
    #
    #   if is_in_trial
    #     assert_empty invoices, 'Should NOT bill because trial check uses local time'
    #   else
    #     assert_not_empty invoices, 'Should bill because UTC time is after trial end'
    #   end
    # end
  end
end
