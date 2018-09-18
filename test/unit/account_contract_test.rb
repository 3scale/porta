require 'test_helper'

class AccountContractTest < ActiveSupport::TestCase

  test 'be valid with an account plan' do
    account_plan = FactoryGirl.create :account_plan
    account_contract = AccountContract.new plan: account_plan

    assert_valid account_contract
  end

  test 'not be valid with an application plan' do
    app_plan = FactoryGirl.create :application_plan
    account_contract = AccountContract.new plan: app_plan

    refute_valid account_contract
    assert_includes account_contract.errors[:plan], 'plan must be an AccountPlan'
  end

  test 'not be valid with a service plan' do
    service_plan = FactoryGirl.create :service_plan
    account_contract = AccountContract.new plan: service_plan

    refute_valid account_contract
    assert_includes account_contract.errors[:plan], 'plan must be an AccountPlan'
  end

  test 'account contract states depends on account state (provider)' do
    account = FactoryGirl.create :simple_provider, state: 'pending'
    account_plan = FactoryGirl.create :account_plan

    account_contract = account.buy!(account_plan)
    assert account.pending?
    assert account_contract.pending?

    account.approve!
    account_contract.reload
    assert account_contract.live?

    account.suspend!
    account_contract.reload
    assert account_contract.suspended?

    account.resume!
    account_contract.reload
    assert account_contract.live?
  end

  test 'account contract states depends on account state (developer pending)' do
    account = FactoryGirl.create :simple_account, state: 'pending'
    account_plan = FactoryGirl.create :account_plan

    account_contract = account.buy!(account_plan)
    assert account.pending?
    assert account_contract.pending?

    account.approve!
    account_contract.reload
    assert account_contract.live?
  end

  test 'account contract states depends on account state (developer created)' do
    account = FactoryGirl.create :simple_account, state: 'created'
    account_plan = FactoryGirl.create :account_plan

    account_contract = account.buy!(account_plan)
    assert account.created?
    assert account_contract.pending?

    account.approve!
    account_contract.reload
    assert account_contract.live?
  end
end
