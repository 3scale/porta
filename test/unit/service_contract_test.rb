# frozen_string_literal: true

require 'test_helper'

class ServiceContractTest < ActiveSupport::TestCase
  test 'plan class should be valid with an service plan' do
    service_plan = FactoryBot.create(:service_plan)
    service_contract = ServiceContract.new(plan: service_plan)

    assert service_contract.valid?
  end

  test 'plan class should not be valid with an application plan' do
    app_plan = FactoryBot.create(:application_plan)
    service_contract = ServiceContract.new(plan: app_plan)

    assert_not service_contract.valid?
    assert_match /must be a ServicePlan/, service_contract.errors[:plan].first
  end

  test 'plan class should not be valid with an account plan' do
    acc_plan = FactoryBot.create(:account_plan)
    service_contract = ServiceContract.new(plan: acc_plan)

    assert_not service_contract.valid?
    assert_match /must be a ServicePlan/, service_contract.errors[:plan].first
  end

  test 'bought_service_contracts' do
    service = FactoryBot.create(:simple_service)
    assert ServiceContract.issued_by(service).count
  end

  test '.provided_by scope' do
    provider1 = FactoryBot.create(:simple_provider)
    provider2 = FactoryBot.create(:simple_provider)
    p1_service1 = FactoryBot.create(:simple_service, account: provider1)
    p1_service2 = FactoryBot.create(:simple_service, account: provider1)
    p2_service3 = FactoryBot.create(:simple_service, account: provider2)

    # Default service plans are created on service creation, we destroy them for a clean comparison
    p1_service1.service_plans.destroy_all
    p1_service2.service_plans.destroy_all
    p2_service3.service_plans.destroy_all

    p1_s1_plan = FactoryBot.create(:simple_service_plan, issuer: p1_service1)
    p1_s2_plan = FactoryBot.create(:simple_service_plan, issuer: p1_service2)
    p2_s3_plan = FactoryBot.create(:simple_service_plan, issuer: p2_service3)

    p1_contracts = FactoryBot.create_list(:simple_service_contract, 2, plan: p1_s1_plan) +
                   FactoryBot.create_list(:simple_service_contract, 3, plan: p1_s2_plan)
    p2_contracts = FactoryBot.create_list(:simple_service_contract, 4, plan: p2_s3_plan)

    assert_same_elements p1_contracts, ServiceContract.provided_by(provider1).to_a
    assert_same_elements p2_contracts, ServiceContract.provided_by(provider2).to_a
  end
end
