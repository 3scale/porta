require 'test_helper'

class ServiceContractTest < ActiveSupport::TestCase
  context 'plan class validation' do

    should 'be valid with an service plan' do
      service_plan = FactoryBot.create :service_plan
      service_contract = ServiceContract.new :plan => service_plan

      assert service_contract.valid?
    end

    should 'not be valid with an application plan' do
      app_plan = FactoryBot.create :application_plan
      service_contract = ServiceContract.new :plan => app_plan

      assert !service_contract.valid?
      assert_match /must be a ServicePlan/, service_contract.errors[:plan].first
    end

    should 'not be valid with an account plan' do
      acc_plan = FactoryBot.create :account_plan
      service_contract = ServiceContract.new :plan => acc_plan

      assert !service_contract.valid?
      assert_match /must be a ServicePlan/, service_contract.errors[:plan].first
    end

  end

  test 'bought_service_contracts' do
    service = FactoryBot.create(:simple_service)
    assert ServiceContract.issued_by(service).count
  end
end
