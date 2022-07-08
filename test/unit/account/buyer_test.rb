# frozen_string_literal: true

require 'test_helper'

class Account::BuyerTest < ActiveSupport::TestCase
  subject { @account || Account.new }

  should belong_to(:provider_account)

  should have_many(:contracts)
  should have_many(:bought_plans).through(:contracts)

  should have_one(:bought_account_contract)
  should have_one(:bought_account_plan).through(:bought_account_contract)

  should have_many(:bought_cinstances)
  should have_many(:bought_application_plans).through(:bought_cinstances)

  should have_many(:bought_service_contracts)
  should have_many(:bought_service_plans).through(:bought_service_contracts)

  test '#has_bought_cinstance?' do
    buyer = FactoryBot.create(:simple_buyer)

    assert_not buyer.has_bought_cinstance?

    FactoryBot.create(:cinstance, user_account: buyer)
    assert buyer.has_bought_cinstance?
  end

  test "factory simple buyer should not have domains" do
    buyer = FactoryBot.build(:simple_buyer)
    assert_nil buyer.internal_domain
    assert_nil buyer.internal_domain
  end

  test "factory simple account should include 'simple' in domain" do
    buyer = FactoryBot.build(:simple_account)
    assert_match(/simple/, buyer.internal_domain)
  end

  # TODO: when the separation of accounts in Buyer, Provider and Master is done
  # this test will make no sense, now is kind of paranoic
  test 'after created should have no services and no s3_prefix' do
    @provider = FactoryBot.create(:provider_account)
    buyer = Account.new(org_name: "buyer", provider_account: @provider)
    buyer.buyer = true
    buyer.save!

    assert buyer.buyer?
    assert_empty buyer.services
    assert_nil buyer.s3_prefix
  end

  class BuyerWithBoughtPlansTest < ActiveSupport::TestCase
    setup do
      @provider = FactoryBot.create(:provider_account)
      @acc_plan = FactoryBot.create(:account_plan, issuer: @provider)
      @buyer = FactoryBot.create(:simple_buyer, provider_account: @provider)
      @acc_contract = FactoryBot.create(:account_contract, plan: @acc_plan, user_account: @buyer)

      @provider.config.set!(:multiple_applications, true)
      @provider.save!

      services = FactoryBot.create_list(:service, 2, account: @provider)
      @service_one, @service_two = services

      @service_plans = services.map { |service| FactoryBot.create(:service_plan, issuer: service) }
      @service_contracts = @service_plans.map { |plan| FactoryBot.create(:service_contract, plan: plan, user_account: @buyer) }

      @application_plans = services.map { |service| FactoryBot.create_list(:application_plan, 2, issuer: service) }.flatten
      @cinstances = @application_plans.map.with_index { |plan, i| FactoryBot.create(:cinstance, plan: plan, user_account: @buyer) }

      @contracts = @service_contracts + @cinstances + [@acc_contract]
      @plans = @service_plans + @application_plans + [@acc_plan]
    end

    test 'Account#bought_account_contract should return only one bought account contract' do
      assert_equal @acc_contract, @buyer.bought_account_contract
    end

    test 'Account#bought_account_plan should return only one bought account plan' do
      assert_equal @acc_plan, @buyer.bought_account_plan
    end

    test 'Account#bought_cinstances should return all bought cinstances' do
      assert_same_elements @cinstances, @buyer.bought_cinstances
    end

    test 'Account#bought_application_plans should return all bought application plans' do
      assert_same_elements @cinstances.map(&:plan), @buyer.bought_application_plans
    end

    test 'Account#bought_application_plans should return only scoped plans when called with issued_by scope' do
      assert_same_elements @application_plans.select {|p| p.issuer == @service_one },
                           @buyer.bought_application_plans.issued_by(@service_one)
    end

    test 'Account#bought_plans should return all bought plans' do
      assert_same_elements @plans, @buyer.bought_plans
    end

    test 'Account#bought_plans should return only scoped plans when called with issued_by scope' do
      assert_same_elements @plans.select {|plan| plan.issuer == @service_one },
                           @buyer.bought_plans.issued_by(@service_one)
    end

    test 'Account#contracts should return all contracts' do
      assert_same_elements @contracts, @buyer.contracts
    end

    test 'Account#contracts should return only scoped contracts when called with issued_by scope' do
      assert_same_elements @plans.select {|plan| plan.issuer == @service_two },
                           @buyer.bought_plans.issued_by(@service_two)
    end
  end

  test 'Account#bought_plan' do
    provider_account = FactoryBot.create(:provider_account)
    service = FactoryBot.create(:simple_service, account: provider_account)
    plan = FactoryBot.create(:application_plan, service: service)

    buyer_account = FactoryBot.create(:simple_buyer, provider_account: provider_account)
    buyer_account.buy(plan)

    assert_equal plan, buyer_account.bought_plan
  end

  test 'Account#feature_allowed? return false if account has no bought cinstance' do
    provider_account = FactoryBot.create(:simple_provider)
    buyer_account = FactoryBot.create(:simple_account, provider_account: provider_account)

    assert_not buyer_account.feature_allowed?(:world_domination)
  end

  test 'forum is not created for buyers' do
    account = FactoryBot.create(:simple_buyer)
    assert_nil account.forum
  end

  test '#destroy returns false if buyer has unresolved invoices' do
    invoice = FactoryBot.create(:invoice)
    buyer = invoice.buyer

    assert_equal false, buyer.destroy
    assert buyer.errors[:invoices].presence

    invoice.cancel
    assert_equal true, buyer.destroy.destroyed?
  end
end
