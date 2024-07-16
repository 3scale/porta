# frozen_string_literal: true

require 'test_helper'

class ContractTest < ActiveSupport::TestCase
  test '#by_account' do
    buyer = FactoryBot.create(:buyer_account)
    provider = buyer.provider_account
    [buyer, provider].each { |account| FactoryBot.create_list(:application, 2, user_account: account) }

    assert_same_elements Contract.where(user_account: buyer.id).pluck(:id), Contract.by_account(buyer.id).pluck(:id)
    assert_same_elements Contract.where(user_account: provider.id).pluck(:id), Contract.by_account(provider.id).pluck(:id)
  end

  test '#have_paid_on' do
    recent_date = (5.days - 1.minute).ago
    old_date = (5.days + 1.day).ago

    paid_apps = [
      FactoryBot.create(:application, paid_until: recent_date, variable_cost_paid_until: nil),
      FactoryBot.create(:application, paid_until: nil, variable_cost_paid_until: recent_date),
      FactoryBot.create(:application, paid_until: recent_date, variable_cost_paid_until: old_date),
      FactoryBot.create(:application, paid_until: old_date, variable_cost_paid_until: recent_date)
    ]
    unpaid_apps = [
      FactoryBot.create(:application, paid_until: old_date, variable_cost_paid_until: nil),
      FactoryBot.create(:application, paid_until: nil, variable_cost_paid_until: old_date),
      FactoryBot.create(:application, paid_until: old_date, variable_cost_paid_until: old_date)
    ]

    assert_raise(ArgumentError) { Contract.have_paid_on.pluck(:id) }
    response_paid_apps = Contract.have_paid_on(5.days.ago).pluck(:id)
    paid_apps.each { |paid_app| assert_includes response_paid_apps, paid_app.id }
    unpaid_apps.each { |unpaid_app| assert_not_includes response_paid_apps, unpaid_app.id }
  end

  test '#plan_changed is notified after commit' do
    plan = FactoryBot.create(:account_plan, issuer: FactoryBot.create(:simple_account))
    contract = FactoryBot.create(:account_contract, plan: plan)

    other_plan = FactoryBot.create(:account_plan, issuer: FactoryBot.create(:simple_account))

    Contract.transaction do
      contract.change_plan!(other_plan)

      contract.expects(:notify_observers).with(:plan_changed).once
      contract.expects(:notify_observers).with(:bill_variable_for_plan_changed, kind_of(Plan)).once
    end

    # testing that it is not notified again
    contract.save!
  end

  test '#plan_changed is notified just once' do
    plan = FactoryBot.create(:account_plan, issuer: FactoryBot.create(:simple_account))
    contract = FactoryBot.create(:account_contract, plan: plan)

    ## explicit transaction
    other_plan = FactoryBot.create(:account_plan, issuer: FactoryBot.create(:simple_account))

    contract.expects(:notify_observers).with(:plan_changed).once
    contract.expects(:notify_observers).with(:bill_variable_for_plan_changed, kind_of(Plan)).once

    Contract.transaction do
      contract.change_plan!(other_plan)
    end

    ## just save
    other_contract = FactoryBot.create(:account_contract, plan: plan)

    other_contract.expects(:notify_observers).with(:plan_changed).once
    other_contract.expects(:notify_observers).with(:bill_variable_for_plan_changed, kind_of(Plan)).once

    other_contract.change_plan!(other_plan)
  end

  test 'by_name' do
    assert Contract.by_name('foo').count
  end

  test 'provider_account' do
    contract = FactoryBot.build_stubbed(:simple_cinstance)
    assert_equal contract.provider_account_id, contract.provider_account.id
  end

  test '#paid? be delegated to plan' do
    buyer = FactoryBot.create(:buyer_account)
    service = buyer.provider_account.first_service!
    #making the service subscribeable
    service.publish!
    @plan = service.service_plans.first

    @contract = buyer.buy! @plan
    assert_not @plan.paid?
    assert_not @contract.paid?
    @plan.update(cost_per_month: 10.0)

    assert @plan.reload.paid?
    assert @contract.reload.paid?
  end

  test '.permitted_for' do
    cinstances = FactoryBot.create_list(:simple_cinstance, 2)
    user = FactoryBot.build(:member)

    user.stubs(forbidden_some_services?: false)
    permitted_contract_ids = Contract.permitted_for(user).pluck(:id)
    cinstances.each { |contract| assert_includes(permitted_contract_ids, contract.id) }

    user.stubs(forbidden_some_services?: true)
    user.stubs(member_permission_service_ids: [cinstances.first.service_id])
    assert_equal [cinstances.first.id], Contract.permitted_for(user).pluck(:id)
  end

  test '#bill_for' do
    invoice = FactoryBot.create(:invoice)
    month = Month.new(Time.zone.now)

    contract = FactoryBot.create(:simple_cinstance, paid_until: 1.day.ago)

    contract.bill_for(month, invoice)

    # Because DB value do not have fraction of seconds but Time.zone.now does
    assert_in_delta month.end.to_time.end_of_day, contract.paid_until, 1.second
  end

  test '#billable' do
    pending_contract = FactoryBot.create(:simple_cinstance)
    # Needed because of a callback `before_create :accept_on_create`
    pending_contract.update_attribute :state, :pending # rubocop:disable Rails/SkipsModelValidations

    provider = FactoryBot.build_stubbed(:simple_provider)
    buyer = pending_contract.user_account
    buyer.stubs(provider_account: provider)
    active_contract = FactoryBot.create(:simple_cinstance, state: 'live', user_account: buyer)

    provider.stubs(:provider_can_use?).with(:billable_contracts).returns(true)
    assert_not_includes buyer.billable_contracts, pending_contract
    assert_includes buyer.billable_contracts, active_contract

    provider.stubs(:provider_can_use?).with(:billable_contracts).returns(false)
    assert_includes buyer.billable_contracts, pending_contract
    assert_includes buyer.billable_contracts, active_contract
  end

  test 'bill plan change with bad period due to time zone' do
    Time.zone = 'CET'
    travel_to(Date.parse('2018-01-17')) do
      provider = FactoryBot.create(:simple_provider)
      contract = FactoryBot.create(:simple_cinstance, trial_period_expires_at: nil)
      other_plan = FactoryBot.create(:simple_application_plan, service: contract.service, cost_per_month: 3100.0)
      Finance::PrepaidBillingStrategy.create!(account: provider, currency: 'EUR')

      System::ErrorReporting.expects(:report_error).with(instance_of(Finance::PrepaidBillingStrategy::BadPeriodError)).never
      contract.change_plan!(other_plan)
    end
  end

  class CanChangePlan < ActiveSupport::TestCase
    def setup
      @provider = FactoryBot.create(:provider_account)
      @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)

      @service_plan = FactoryBot.create(:service_plan, issuer: @provider.first_service!)

      @provider.set_change_service_plan_permission!(:none)
    end

    test "service contract can change plan only if live, allowed by issuer and published plan exists" do
      contract = @service_plan.create_contract_with(@buyer)
      contract.suspend!

      @provider.set_change_service_plan_permission!(:request)
      assert_equal false, contract.can_change_plan?

      @service_plan.publish!
      assert_equal false, contract.can_change_plan?

      contract.resume!
      assert_equal true, contract.can_change_plan?

      assert_not contract.can_change_plan?(nil)
    end
  end

  test 'destroy customized plan callback only runs when the plan is not scheduled for deletion' do
    original_plan = FactoryBot.create(:simple_application_plan)
    plan_async_deletion, plan_sync_deletion = FactoryBot.create_list(:simple_application_plan, 2, original: original_plan)
    plan_async_deletion.service.update(state: :deleted)
    contract_async_deletion, contract_sync_deletion = [plan_async_deletion.reload, plan_sync_deletion].map do |plan|
      FactoryBot.create(:simple_cinstance, plan: plan)
    end

    [contract_async_deletion, contract_sync_deletion].each(&:destroy!)

    assert Plan.exists?(plan_async_deletion.id)
    assert_not Plan.exists?(plan_sync_deletion.id)
  end
end
