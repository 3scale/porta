# frozen_string_literal: true

require 'test_helper'

class Finance::BillVariableForPlanChangedTest < ActiveSupport::TestCase
  attr_reader :contract, :app_plan

  setup do
    @contract = FactoryBot.build_stubbed(:contract)
    account = FactoryBot.build_stubbed(:simple_account)
    @app_plan = FactoryBot.build_stubbed(:application_plan)

    contract.stubs(:provider_account).returns(account)
    account.stubs(:provider_can_use?).with(:instant_bill_plan_change).returns(true)

    @org_tz = ENV["TZ"]
  end

  teardown do
    ENV["TZ"] = @org_tz
  end

  test "bill for variable on 1st day of month UTC" do
    Timecop.travel(Time.now.beginning_of_month) # rubocop:disable Rails/TimeZone we don't use timezones in billing

    contract.expects(:save).never
    contract.notify_observers(:bill_variable_for_plan_changed, app_plan)
  end

  test "bill for variable not on first day" do
    Timecop.travel(Time.now.beginning_of_month - 15.days) # rubocop:disable Rails/TimeZone we don't use timezones in billing

    contract.expects(:save).returns(true)
    contract.notify_observers(:bill_variable_for_plan_changed, app_plan)
  end

  test "no variable billing on 1st day of month local time" do
    # this changes server and client local time to China Standard Time (+8)
    ENV["TZ"] = "Asia/Shanghai"

    # this is 4 hours before beginning of month in UTC and 4 after local
    Timecop.travel(Time.now.utc.beginning_of_month - 4.hours)

    contract.expects(:save).never
    contract.notify_observers(:bill_variable_for_plan_changed, app_plan)
  end

  test "no variable billing if last billed until is today" do
    Timecop.freeze
    contract.stubs(:variable_cost_paid_until).returns(Time.now.to_date) # rubocop:disable Rails/TimeZone we don't use timezones in billing

    contract.expects(:save).never
    contract.notify_observers(:bill_variable_for_plan_changed, app_plan)
  end
end
