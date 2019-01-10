require 'test_helper'

class Logic::ContractingTest < ActiveSupport::TestCase

  def test_can_create_application_contract
    provider = FactoryBot.create(:simple_provider)
    not_available = FactoryBot.create(:simple_service, account: provider)
    _plan = FactoryBot.create(:simple_application_plan, issuer: not_available)
    with_default_plan = FactoryBot.create(:simple_service, account: provider)
    with_default_plan.update_columns(default_application_plan_id: 42)
    with_published_plan = FactoryBot.create(:simple_service, account: provider)
    published_plan1 = FactoryBot.create(:simple_application_plan, issuer: with_published_plan)
    published_plan2 = FactoryBot.create(:simple_application_plan, issuer: with_published_plan)
    [ published_plan1, published_plan2 ].each { |plan| plan.update_columns(state: 'published') }

    available = provider.services.can_create_application_contract.order(:id)

    assert_equal [with_default_plan, with_published_plan], available.to_a
  end

  def test_services_can_create_app_on
    provider = FactoryBot.create(:simple_provider)
    buyer = FactoryBot.create(:simple_buyer, provider_account: provider)
    service_with_contract = FactoryBot.create(:simple_service, account: provider)
    plan = FactoryBot.create(:simple_service_plan, issuer: service_with_contract)
    _contract = FactoryBot.create(:simple_service_contract, plan: plan, user_account: buyer)
    _service_without = FactoryBot.create(:simple_service, account: provider)
    service_with_plan = FactoryBot.create(:simple_service, account: provider)
    service_with_plan.update_columns(default_application_plan_id: 42)

    available = buyer.services_can_create_app_on

    assert_equal 0, available.count

    service_with_contract.update_columns(default_application_plan_id: 42)

    assert_equal 1, available.count
  end
end
