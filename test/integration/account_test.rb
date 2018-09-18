require 'test_helper'

class AccountTest < ActionDispatch::IntegrationTest

  test 'account is created with the default application plan instead of with the first one' do
    master_service = master_account.services.first
    ApplicationPlan.delete_all

    # Create and contract master_plan for the master account
    master_plan = ApplicationPlan.create!(issuer: master_service, name: 'master_plan')
    master_service.update_attribute(:default_application_plan, master_plan)
    master_plan.create_contract_with! master_account

    # Create enterprise plan for the master providers
    enterprise_plan = ApplicationPlan.create!(issuer: master_service, name: 'enterprise')
    master_service.application_plans.default!(enterprise_plan)

    account = FactoryGirl.create(:provider_account)
    assert_equal [enterprise_plan], account.bought_application_plans
  end

  class WebhooksTest < ActionDispatch::IntegrationTest
    disable_transactional_fixtures!

    include WebHookTestHelpers

    def setup
      @account = FactoryGirl.create(:buyer_account)
      @provider = @account.provider_account

      @user = @account.admins.first

      User.current = nil
    end

    def teardown
      User.current = nil
    end

    test 'be pushed if the account is created by user' do
      buyer = FactoryGirl.build(:simple_buyer, provider_account: @provider)
      user = FactoryGirl.build(:simple_user, account: buyer)

      assert User.current = user, 'missing user'

      fires_webhook(user)
      fires_webhook(buyer)

      Account.transaction do
        buyer.save!
        user.save!
      end
    end

    test 'not be pushed if the account is not created by user' do
      buyer = FactoryGirl.build(:simple_buyer, provider_account: @provider)
      User.current = nil

      fires_webhook.never

      buyer.save!
    end

    test 'be pushed if the account is updated by user' do
      User.current = @user

      fires_webhook(@account)

      # in rails 3 a touch wont trigger callbacks
      @account.org_name += " "
      @account.save!
    end

    test 'not be pushed if the account was not updated by user' do
      User.current = nil

      fires_webhook.never

      # in rails 3 a touch wont trigger callbacks
      @account.org_name += " "
      @account.save!
    end

    #TODO: is this better to be tested in account_contract tests?
    # the thing is account.change_plan! looks like making sense to me
    test 'be pushed if account plan is changed by an user' do
      account_plan = FactoryGirl.create :account_plan, :issuer => @provider
      other_account_plan = FactoryGirl.create :account_plan, :issuer => @provider

      @account.buy!(account_plan)
      @account.reload

      User.current = @user

      fires_webhook(@account, 'plan_changed').once

      assert @account.bought_account_contract.change_plan! other_account_plan
    end

    #TODO: is this better to be tested in account_contract tests?
    # the thing is account.change_plan! looks like making sense to me
    test 'not be pushed if account plan is not changed by an user' do
      account_plan = FactoryGirl.create :account_plan, :issuer => @provider
      other_account_plan = FactoryGirl.create :account_plan, :issuer => @provider
      @account.buy!(account_plan)
      @account.reload

      User.current = nil

      fires_webhook.never

      assert @account.bought_account_contract.change_plan! other_account_plan
    end

    test 'be pushed asynchronously if the account is destroyed by user' do
      User.current = @user

      # WebHook.expects(:push).with(@provider.admins.first, { :event => "deleted",
      #                               :user_id => @user.id })

      fires_webhook(@account, 'deleted')
      fires_webhook(@user, 'deleted')

      @account.destroy
    end

    test 'not be pushed if the account was not destroyed by user' do
      User.current = nil

      fires_webhook.never

      @account.destroy
    end
  end
end
