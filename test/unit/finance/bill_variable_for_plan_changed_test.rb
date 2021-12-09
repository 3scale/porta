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

    ENV["TZ"] = "UTC"
  end

  test "no variable billing on 1st day utc" do
    Timecop.travel(Time.now.utc.beginning_of_month + 1.day - 1.second)

    contract.expects(:save).never
    contract.notify_observers(:bill_variable_for_plan_changed, app_plan)
  end

  test "variable billing after 1st day utc" do
    Timecop.travel(Time.now.utc.beginning_of_month + 1.day)

    contract.expects(:save).returns(true)
    contract.notify_observers(:bill_variable_for_plan_changed, app_plan)
  end

  test "no variable billing on 1st day of month local time" do
    # this changes server and client local time to China Standard Time (+8)
    ENV["TZ"] = "Asia/Shanghai"

    # this is 4 hours before beginning of month in UTC and 4 after local
    Timecop.travel(Time.zone.now.beginning_of_month - 4.hours)

    contract.expects(:save).never
    contract.notify_observers(:bill_variable_for_plan_changed, app_plan)
  end

  test "variable billing if last billed until is yesterday" do
    contract.stubs(:variable_cost_paid_until).returns(Time.zone.now.to_date - 1.day)

    contract.expects(:save).returns(true)
    contract.notify_observers(:bill_variable_for_plan_changed, app_plan)
  end

  test "no variable billing if last billed until is today" do
    Timecop.freeze
    contract.stubs(:variable_cost_paid_until).returns(Time.zone.now.to_date)

    contract.expects(:save).never
    contract.notify_observers(:bill_variable_for_plan_changed, app_plan)
  end
end
