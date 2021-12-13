# frozen_string_literal: true

require 'test_helper'

class Finance::BillVariableForPlanChangedTest < ActiveSupport::TestCase
  attr_reader :contract, :account, :app_plan

  setup do
    @contract = FactoryBot.build_stubbed(:contract)
    @account  = FactoryBot.build_stubbed(:simple_account)
    @app_plan = FactoryBot.build_stubbed(:application_plan)

    @org_tz = ENV["TZ"]
  end

  teardown do
    ENV["TZ"] = @org_tz
  end

  test "bill for variable" do
    Timecop.travel(15.days.ago) if Time.now.mday == 1 # rubocop:disable Rails/TimeZone we don't use timezones in billing

    contract.stubs(:provider_account).returns(account)
    account.stubs(:provider_can_use?).returns(true)

    contract.expects(:save).returns(true)
    contract.notify_observers(:bill_variable_for_plan_changed, app_plan)
  end

  test "no variable billing on 1st day of month local time" do
    # this changes server and client local time to China Standard Time (+8)
    ENV["TZ"] = "Asia/Shanghai"

    # this is 4 hours before beginning of month in UTC and 4 after local
    Timecop.travel(Time.zone.now.beginning_of_month - 4.hours)

    contract.stubs(:provider_account).returns(account)
    account.stubs(:provider_can_use?).returns(true)

    contract.expects(:save).never
    contract.notify_observers(:bill_variable_for_plan_changed, app_plan)
  end

  test "no variable billing if last billed until is today" do
    contract.stubs(:provider_account).returns(account)
    Timecop.freeze
    contract.stubs(:variable_cost_paid_until).returns(Time.now.to_date) # rubocop:disable Rails/TimeZone we don't use timezones in billing
    account.stubs(:provider_can_use?).returns(true)

    contract.expects(:save).never
    contract.notify_observers(:bill_variable_for_plan_changed, app_plan)
  end
end
