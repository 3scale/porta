require 'test_helper'

class ProviderPlanChangeObserverTest < ActionDispatch::IntegrationTest
  disable_transactional_fixtures!

  def setup
    @observer = ProviderPlanChangeObserver.instance
  end

  def test_plan_changed
    provider = FactoryBot.create(:provider_account)
    assert @observer.plan_changed(provider.bought_cinstance)

    provider.default_service.application_plans.create!(name: 'Default')

    buyer = FactoryBot.create(:buyer_account, provider_account: provider)
    provider.application_plans.first!.create_contract_with(buyer)

    refute @observer.plan_changed(buyer.bought_cinstance)
  end

  def test_observer
    provider = FactoryBot.create(:provider_account)
    other_plan = master_account.default_service.application_plans.create!(name: 'Other Plan')

    application = provider.bought_cinstance

    @observer.expects(:plan_changed).with(application)

    assert application.change_plan!(other_plan)
  end

  def test_activerecord_observers
    assert_includes ActiveRecord::Base.observers, :provider_plan_change_observer
  end
end
