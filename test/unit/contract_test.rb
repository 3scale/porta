require 'test_helper'

class ContractTest < ActiveSupport::TestCase

  disable_transactional_fixtures!

  def test_plan_changed_is_notified_after_commit
    plan = FactoryBot.create(:account_plan, :issuer => FactoryBot.create(:simple_account))
    contract = FactoryBot.create(:contract, :plan => plan)

    other_plan = FactoryBot.create(:account_plan, :issuer => FactoryBot.create(:simple_account))

    Contract.transaction do
      contract.change_plan!(other_plan)

      contract.expects(:notify_observers).with(:plan_changed).once
      contract.expects(:notify_observers).with(:bill_variable_for_plan_changed, kind_of(Plan)).once
    end

    # testing that it is not notified again
    contract.save!
  end

  def test_plan_changed_is_notified_just_once
    plan = FactoryBot.create(:account_plan, :issuer => FactoryBot.create(:simple_account))
    contract = FactoryBot.create(:contract, :plan => plan)

    ## explicit transaction
    other_plan = FactoryBot.create(:account_plan, :issuer => FactoryBot.create(:simple_account))

    contract.expects(:notify_observers).with(:plan_changed).once

    contract.expects(:notify_observers).with(:bill_variable_for_plan_changed, kind_of(Plan)).once

    Contract.transaction do
      contract.change_plan!(other_plan)
    end

    ## just save
    other_contract = FactoryBot.create(:contract, :plan => plan)

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

  context '#paid?' do
    setup do
      buyer = FactoryBot.create :buyer_account
      service = buyer.provider_account.first_service!
      #making the service subscribeable
      service.publish!
      @plan = service.service_plans.first

      @contract = buyer.buy! @plan
    end

    should 'be delegated to plan' do
      assert !@plan.paid?
      assert !@contract.paid?
      @plan.update_attribute :cost_per_month, 10.0

      @plan.reload
      @contract.reload

      assert @plan.paid?
      assert @contract.paid?
    end
  end #paid?


  def test_bill_for
    invoice = FactoryBot.create(:invoice)
    month = Month.new(Time.now)

    contract = FactoryBot.create(:simple_cinstance, paid_until: 1.day.ago)

    contract.bill_for(month, invoice)

    assert_equal month.end.to_time.end_of_day, contract.paid_until
  end

  def test_billable
    pending_contract = FactoryBot.create(:simple_cinstance)
    # Needed because of a callback `before_create :accept_on_create`
    pending_contract.update_attribute :state, :pending

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

  def test_bill_plan_change_with_bad_period_due_to_time_zone
    Time.zone = 'CET'
    Timecop.freeze(Date.parse('2018-01-17')) do
      other_plan = FactoryBot.create(:simple_application_plan, cost_per_month: 3100.0)
      contract = FactoryBot.create(:simple_cinstance, trial_period_expires_at: nil)
      provider = FactoryBot.create(:simple_provider)
      Finance::PrepaidBillingStrategy.create!(account: provider, currency: 'EUR')
      contract.buyer_account.stubs(provider_account: provider)

      System::ErrorReporting.expects(:report_error).with(instance_of(Finance::PrepaidBillingStrategy::BadPeriodError)).never
      contract.change_plan!(other_plan)
    end
  end

  class CanChangePlan < ActiveSupport::TestCase
    def setup
      @provider = FactoryBot.create :provider_account
      @buyer = FactoryBot.create :buyer_account, :provider_account => @provider

      @service_plan = FactoryBot.create :service_plan, :issuer => @provider.first_service!

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

      refute contract.can_change_plan?(nil)
    end
  end
end
