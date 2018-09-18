require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

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

  test "factory simple buyer should not have domains" do
    buyer = FactoryGirl.build(:simple_buyer)
    assert_nil buyer.domain
    assert_nil buyer.self_domain
  end

  test "factory simple account should include 'simple' in domain" do
    buyer = FactoryGirl.build(:simple_account)
    assert_match(/simple/, buyer.domain)
  end

  context 'after created' do
    #TODO: when the separation of accounts in Buyer, Provider and Master is done
    # this test will make no sense, now is kind of paranoic
    should 'have no services and no s3_prefix' do
      @provider =  Factory :provider_account
      buyer = Account.new :org_name => "buyer", :provider_account => @provider
      buyer.buyer = true
      buyer.save!

      assert buyer.buyer?
      assert buyer.services.empty?
      assert_nil buyer.s3_prefix
    end
  end

  context "for buyer" do

    setup do
      @provider =  Factory.create(:provider_account)
      @acc_plan = Factory.create(:account_plan, :issuer => @provider)
      @buyer = Factory.create(:simple_buyer, :provider_account => @provider)
      @acc_contract =  Factory.create(:account_contract, :plan => @acc_plan, :user_account => @buyer)
    end

    context 'with bought plans' do
      setup do
        @provider.config.set!(:multiple_applications, true)
        @provider.save!

        @service_one = Factory(:service, :account => @provider)
        @service_two = Factory(:service, :account => @provider)
        @service_three = Factory(:service, :account => @provider)

        Factory(:service_plan, :issuer => @service_one)
        Factory(:service_plan, :issuer => @service_two)
        Factory(:application_plan, :issuer => @service_two)

        @plans = {
            :service => [
              Factory(:service_plan, :issuer => @service_one),
              Factory(:service_plan, :issuer => @service_two)
            ],
            :application => [
              Factory(:application_plan, :issuer => @service_one),
              Factory(:application_plan, :issuer => @service_one),
              Factory(:application_plan, :issuer => @service_two),
              Factory(:application_plan, :issuer => @service_two)
            ]
        }
        @contracts = []

        @plans[:service].each do |plan|
          @contracts << Factory(:service_contract, :plan => plan, :user_account => @buyer)
        end

        i = 0
        name = "app"
        @plans[:application].each do |plan|
          @contracts << Factory(:cinstance, :plan => plan, :user_account => @buyer, :name => (name + (i += 1).to_s), :description => 'Desc')
        end

        @contracts << @acc_contract
        @plans[:account] = @acc_plan

        @plans = @plans.values.flatten

        @buyer.reload
      end

      context 'Account#bought_account_contract' do
        should 'return only one bought account contract' do
          assert_equal @acc_contract, @buyer.bought_account_contract
        end
      end

      context 'Account#bought_account_plan' do
        should 'return only one bought account plan' do
          assert_equal @acc_plan, @buyer.bought_account_plan
        end
      end

      context 'Account#bought_cinstances' do
        should 'return all bought cinstances' do
          assert_same_elements @contracts.select{|c| c.is_a? Cinstance },
                               @buyer.bought_cinstances
        end
      end

      context 'Account#bought_application_plans' do
        should 'return all bought application plans' do
          assert_same_elements @contracts.select{|c| c.is_a? Cinstance }.map{|c| c.plan },
                               @buyer.bought_application_plans
        end
        should 'return only scoped plans when called with issued_by scope' do
          assert_same_elements @plans.select{|p| p.is_a?(ApplicationPlan) && p.issuer == @service_one },
                               @buyer.bought_application_plans.issued_by(@service_one)
        end

      end

      context 'Account#bought_plans' do
        should 'return all bought plans' do
          assert_same_elements @plans, @buyer.bought_plans
        end

        should 'return only scoped plans when called with issued_by scope' do
          assert_same_elements @plans.select{|plan| plan.issuer == @service_one },
                               @buyer.bought_plans.issued_by(@service_one)
        end
      end

      context 'Account#contracts' do
        should 'return all contracts' do
          assert_same_elements @contracts, @buyer.contracts
        end

        should 'return only scoped contracts when called with issued_by scope' do
          assert_same_elements @plans.select{|plan| plan.issuer == @service_two },
                               @buyer.bought_plans.issued_by(@service_two)
        end
      end

    end

  end

  test 'Account#bought_plan' do
    provider_account = Factory(:provider_account)
    service = Factory(:simple_service, :account => provider_account)
    plan = Factory(:application_plan, :service => service)

    buyer_account = Factory(:simple_buyer, :provider_account => provider_account)
    buyer_account.buy(plan)

    assert_equal plan, buyer_account.bought_plan
  end

  test 'Account#feature_allowed? return false if account has no bought cinstance' do
    provider_account = Factory(:simple_provider)
    buyer_account = Factory(:simple_account, :provider_account => provider_account)

    assert !buyer_account.feature_allowed?(:world_domination)
  end

  test 'forum is not created for buyers' do
     account = Factory(:simple_buyer)
     assert_nil account.forum
  end

  test '#destroy returns false if buyer has unresolved invoices' do
    invoice = Factory(:invoice)
    buyer = invoice.buyer

    assert_equal false, buyer.destroy
    assert buyer.errors[:invoices].presence

    invoice.cancel
    assert_equal true, buyer.destroy.destroyed?
  end
end
