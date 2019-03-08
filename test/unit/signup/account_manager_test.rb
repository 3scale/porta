# frozen_string_literal: true

require 'test_helper'

class Signup::AccountManagerTest < ActiveSupport::TestCase

  include TestHelpers::Events

  class ProviderAccountManagerTest < Signup::AccountManagerTest
    test 'create provider with right params' do
      org_name_param     = 'Alaska'
      signup_result      = signup_account_manager.create(signup_params(different_account_params: {org_name: org_name_param}))
      account            = signup_result.account
      user               = signup_result.user
      imp_config         = ThreeScale.config.impersonation_admin
      impersonation_user = account.users.impersonation_admin!

      # persisted correctly
      assert signup_result.valid?
      assert signup_result.persisted?
      assert_equal 2, signup_result.account.users.count

      # account has the right attributes
      assert_equal manager_account, account.provider_account
      assert_equal org_name_param, account.org_name
      assert_equal valid_account_params[:vat_rate].to_f, account.vat_rate
      refute account.buyer?
      assert account.provider?
      assert account.email_all_users # email_all_users preference (admins and members and not only admins) is set to true
      assert account.sample_data

      # account has the right domains
      org_name_param_downcase = org_name_param.downcase
      assert_equal org_name_param, account.name
      assert_equal org_name_param_downcase, account.subdomain
      assert_equal "#{org_name_param_downcase}-admin", account.self_subdomain
      assert_equal "#{org_name_param_downcase}-admin.#{ThreeScale.config.superdomain}", account.self_domain

      # the main user has the right attributes
      valid_user_params.each do |user_attribute_name, expected_user_attribute_value|
        assert_equal expected_user_attribute_value, user.send(user_attribute_name)
      end
      assert_equal :admin, user.role

      # impersonation_admin user is also created with the right attributes
      assert_equal "#{ThreeScale.config.impersonation_admin['username']}+#{account.self_domain}@#{imp_config['domain']}", impersonation_user.email
      assert_equal '3scale', impersonation_user.first_name
      assert_equal 'Admin', impersonation_user.last_name

      # tenant_id is updated correctly
      assert_equal account.id, account.tenant_id
      account.users.each do |user|
        assert_equal account.id, user.tenant_id
      end

      # should set the limits
      constraints = account.provider_constraints
      assert_nil constraints.max_users
      assert_nil constraints.max_services
      assert constraints.can_create_service?
      assert constraints.can_create_user?

      # only impersonation_admin is active and the account is not approved
      assert impersonation_user.active?
      refute signup_result.user_active?
      refute signup_result.account_approved?

      # publish account created event
      check_events_validity!(type: Accounts::AccountCreatedEvent, count: 1)
    end

    test 'enqueues signup job' do
      signup_account_manager.create(signup_params) do |signup_result|
        SignupWorker.expects(:enqueue).with(signup_result.account)
      end
    end

    test 'create provider with right params and enterprise application plan for on-prem and for saas' do
      account_plan     = master_account.default_account_plan
      service_plan     = manager_account.default_service_plans.first!
      application_plan = manager_account.default_application_plans.first!
      application_plan.update_attribute(:system_name, 'enterprise') # for the switches tested later

      # On-prem
      ThreeScale.config.stubs(onpremises: true)
      signup_result    = signup_account_manager.create(signup_params)
      account          = signup_result.account
      # account has the right plans
      assert_equal account_plan, account.bought_account_plan
      assert_equal [service_plan], account.bought_service_plans
      assert_equal [application_plan], account.bought_application_plans
      # should set the switches to everything is allowed (because it is enterprise and for on-prem it is validated)
      switches = account.settings.switches.except(:end_users)
      switches.each { |_name, switch| assert switch.allowed? }

      # Saas
      ThreeScale.config.stubs(onpremises: false)
      signup_result    = signup_account_manager.create(signup_params)
      account          = signup_result.account
      # account has the right plans
      assert_equal account_plan, account.bought_account_plan
      assert_equal [service_plan], account.bought_service_plans
      assert_equal [application_plan], account.bought_application_plans
      # should set the switches to nothing is allowed (because the enterprise plan for saas is not automatically validated)
      switches = account.settings.switches.except(:end_users)
      switches.each { |_name, switch| refute switch.allowed? }
    end

    test 'create provider with wrong params does not create correctly without org_name' do
      signup_result = signup_account_manager.create(signup_params(different_account_params: { org_name: '' }))

      refute signup_result.valid?
      refute signup_result.persisted?
      signup_errors = signup_result.errors.full_messages
      assert_includes signup_errors, 'Account Domain can\'t be blank'
      assert_includes signup_errors, 'Account Admin domain can\'t be blank'
      assert_includes signup_errors, 'Account Organization/Group Name can\'t be blank'
    end

    test 'creating a provider will create contract only 1 contract with the default application plan' do
      enterprise_plan = manager_account.default_application_plans.first!
      enterprise_plan.update_attribute(:system_name, 'enterprise')
      account = signup_account_manager.create(signup_params).account
      assert account.signup? # assert signup_mode instance variable to true, which skips the application_plan callback
      assert_equal [enterprise_plan], account.bought_application_plans
      assert_equal 'API', account.first_service!.name
    end

    private

    def manager_account
      @manager_account ||= master_account
    end

    def signup_account_manager
      Signup::ProviderAccountManager.new(manager_account)
    end
  end

  class DeveloperAccountManagerTest < Signup::AccountManagerTest

    setup do
      @service = manager_account.first_service!
      @account_plan = FactoryBot.create(:account_plan, :issuer => manager_account, approval_required: false)
      @service_plan = FactoryBot.create(:service_plan, :issuer => @service)
      @application_plan = FactoryBot.create(:application_plan, :issuer => @service)

      manager_account.update_attribute :default_account_plan, @account_plan
      @service.update_attribute :default_service_plan, @service_plan
      @service.update_attribute :default_application_plan, @application_plan
    end

    test 'create does not do signups for users with same email' do
      signup = []

      2.times do
        signup << signup_account_manager.create(signup_params)
      end

      assert signup[0].persisted?
      refute signup[0].account.new_record?
      refute signup[0].user.new_record?

      refute signup[1].persisted?
      assert signup[1].account.new_record?
      assert signup[1].user.new_record?
      refute signup[1].valid?
      assert_includes signup[1].errors.full_messages, 'User Email has already been taken'
    end

    test 'create does not create correctly without username' do
      signup_result = signup_account_manager.create(signup_params(different_user_params: {username: ''}))
      refute signup_result.valid?
      refute signup_result.persisted?
      assert_match /User Username is too short/, signup_result.errors.full_messages.to_sentence
    end

    test 'create developer with the right params' do
      signup_result = signup_account_manager.create(signup_params)
      account = signup_result.account

      # persisted correctly
      assert signup_result.valid?
      assert signup_result.persisted?
      assert_equal 1, account.users.count

      # account has the right attributes
      assert_equal manager_account, account.provider_account
      assert_equal valid_account_params[:org_name], account.org_name
      assert_equal valid_account_params[:vat_rate].to_f, account.vat_rate
      assert account.buyer?
      refute account.provider?

      # account has the right plans
      assert_equal @account_plan, account.bought_account_plan
      assert_equal [@service_plan], account.bought_service_plans
      assert_equal [@application_plan], account.bought_application_plans

      # the main user has the right attributes
      user = signup_result.user
      valid_user_params.each do |user_attribute_name, expected_user_attribute_value|
        assert_equal expected_user_attribute_value, user.send(user_attribute_name)
      end
      assert_equal :admin, user.role

      # publish account created event
      #   This needs to be tested because the AccountCreatedEvent is done by calling to AccountManager#publish_related_event,
      #   but the other 2 are done by observers when the contract_plan is done, and for that these needs to be done after saving the user,
      #   otherwise this will not work because MessageObserver#after_create will receive a contract with an empty user
      check_events_validity!(type: Accounts::AccountCreatedEvent, count: 1)
      check_events_validity!(type: Applications::ApplicationCreatedEvent, count: 1, opts: {provider_id: manager_account.id})
      check_events_validity!(type: ServiceContracts::ServiceContractCreatedEvent, count: 1, opts: {provider_id: manager_account.id})
    end

    test 'create developer without account plan approval required and minimal signup' do
      @account_plan.update_attribute(:approval_required, false)
      signup_result = signup_account_manager.create(signup_params(different_user_params: {signup_type: :minimal}))

      # the user is active and the account is approved
      assert signup_result.persisted?
      assert signup_result.user_active?
      assert signup_result.account_approved?
    end

    test 'create developer with account plan approval required and minimal signup' do
      # The only difference is result.user_activate_on_minimal_signup? should return false, and it only happens if the contract_plans goes before this
      @account_plan.update_attribute(:approval_required, true)
      signup_result = signup_account_manager.create(signup_params(different_user_params: {signup_type: :minimal}))
      account = signup_result.account

      # the user is pending and the account is created
      assert signup_result.persisted?
      assert_equal 'pending', signup_result.user.state
      assert_equal 'created', account.state
    end

    private

    def manager_account
      @manager_account ||= FactoryBot.create(:provider_account)
    end

    def signup_account_manager
      Signup::DeveloperAccountManager.new(manager_account)
    end
  end

  class PlansWithDefaultsTest < Signup::AccountManagerTest
    setup do
      @manager_account ||= FactoryBot.create(:provider_account)
      @service = @manager_account.first_service!
      @manager_account.update_attribute :default_account_plan, nil
      @service.update_attribute :default_service_plan, nil
      @service.update_attribute :default_application_plan, nil
      @plans = Signup::AccountManager::PlansWithDefaults.new @manager_account
    end

    context 'without default plans' do
      should 'be invalid on account plan without passed plans' do
        @plans.selected = []

        assert @plans.errors?
        assert_match /Account plan is required/i, @plans.errors.to_sentence
        assert @plans.to_a.empty?
      end

      should 'yield errors to proc' do
        errors = []
        @plans.error_proc = proc { |error| errors << error }
        @plans.selected = []

        assert @plans.errors?
        assert_equal errors, @plans.errors
      end
    end

    context 'with default account plan' do
      setup do
        @account_plan = FactoryBot.create(:account_plan, :issuer => @manager_account)
        @manager_account.update_attribute :default_account_plan, @account_plan
      end

      should 'select default account plan and nothing else' do
        @plans.selected = []

        assert @plans.valid?
        assert_equal [@account_plan], @plans.to_a
      end

      context 'and default service plan' do
        setup do
          @service_plan = FactoryBot.create(:service_plan, :issuer => @service)
          @service.update_attribute :default_service_plan, @service_plan
        end

        should 'select default account and service plan' do
          @plans.selected = []

          assert @plans.valid?
          assert_equal [@account_plan, @service_plan], @plans.to_a
        end

        should 'have error on service plan when tries to subscribe two plans' do
          service_plans = @service.service_plans
          @plans.selected = service_plans

          assert @plans.errors?
          assert_equal 1, @plans.errors.size
          assert_match /subscribe only one plan per service/, @plans.errors.to_sentence
        end

        context 'and default application plan' do
          setup do
            @application_plan = FactoryBot.create(:application_plan, :issuer => @service)
            @service.update_attribute :default_application_plan, @application_plan
          end

          should 'select default account, service and application plan' do
            @plans.selected = []

            assert @plans.valid?
            assert_equal [@account_plan, @service_plan, @application_plan], @plans.to_a
          end
        end
      end

      context 'and default application plan without service plan' do
        setup do
          @application_plan = FactoryBot.create(:application_plan, :issuer => @service)
          @service.update_attribute :default_application_plan, @application_plan
        end

        should 'select only account plan' do
          @plans.selected = []

          assert @plans.valid?
          assert_equal [@account_plan], @plans.to_a
        end

        should 'select all when passed service plan' do
          service_plan = @service.service_plans.first!
          @plans.selected = [service_plan]

          assert @plans.valid?
          assert_equal [@account_plan, service_plan, @application_plan], @plans.to_a
        end


        should 'have error on application plan when explicitly selected' do
          @plans.selected = [@application_plan]

          assert @plans.errors?
          assert_equal 1, @plans.errors.size
          assert_match /Couldn't find a Service Plan for/, @plans.errors.to_sentence
        end

        should 'work when provider has service plans disabled and default plan' do
          service_plan = @service.service_plans.first!
          @manager_account.settings.service_plans_ui_visible = false

          @plans.selected = []

          assert @plans.valid?
          assert_equal [ @account_plan, service_plan , @application_plan], @plans.to_a
        end

        should 'work when provider has service plans disabled' do
          service_plan = @service.service_plans.first!
          @manager_account.settings.service_plans_ui_visible = false

          @plans.selected = [@application_plan]

          assert @plans.valid?
          assert_equal [ @account_plan, service_plan , @application_plan], @plans.to_a
        end

        should 'have error when rolling update is not active' do
          service_plan = @service.service_plans.first!
          service_plan.update_columns(state: 'published')
          @manager_account.settings.service_plans_ui_visible = false

          Logic::RollingUpdates.stubs(skipped?: true)

          @plans.selected = [@application_plan]

          refute @plans.valid?
          assert_equal [ @account_plan, @application_plan ], @plans.to_a
          assert_match /Couldn't find a Service Plan/, @plans.errors.to_sentence
        end

        should 'work without the rolling update' do
          service_plan = @service.service_plans.first!
          service_plan.update_columns(state: 'published')
          @manager_account.settings.service_plans_ui_visible = false

          Logic::RollingUpdates.stubs(skipped?: true)

          @plans.selected = []

          assert @plans.valid?
          assert_equal [ @account_plan], @plans.to_a
        end

        should 'have error with hidden service plan when provider has service plans disabled' do
          service_plan = @service.service_plans.first!
          service_plan.update_columns(state: 'hidden') # default plans used to be hidden
          @manager_account.settings.service_plans_ui_visible = false

          @plans.selected = [@application_plan]

          refute @plans.valid?
          assert_equal [ @account_plan, @application_plan ], @plans.to_a
          assert_match /Couldn't find a Service Plan/, @plans.errors.to_sentence
        end
      end
    end
  end

  class DeadlockTest < ActiveSupport::TestCase
    disable_transactional_fixtures!

    setup do
      @provider_account = FactoryBot.create(:provider_account)

      buyer_params = { org_name: 'My company' }
      user_params = { username: 'new_user', email: 'new.user@company.com', signup_type: :minimal }
      plan_defaults = { ApplicationPlan => { :name => 'API signup', :description => 'API signup', :create_origin => 'api' } }
      @signup_params = Signup::SignupParams.new(account_attributes: buyer_params, user_attributes: user_params, defaults: plan_defaults)
    end

    test 'records are correctly saved after deadlock retry' do
      manager = Signup::DeveloperAccountManager.new(@provider_account)

      User.any_instance.stubs(:save!)
        .raises(ActiveRecord::StatementInvalid, 'Deadlock found when trying to get lock')
        .then.returns(true)

      result = manager.create(@signup_params)

      assert result.persisted?

      buyer_account = result.account
      buyer_user = result.user

      assert_equal 'My company', buyer_account.org_name
      assert_equal 'new_user', buyer_user.username
      assert_equal 'new.user@company.com', buyer_user.email
    end
  end

  private

  def signup_params(different_account_params: {}, different_user_params: {})
    Signup::SignupParams.new(user_attributes: valid_user_params(different_user_params: different_user_params), account_attributes: valid_account_params(different_account_params: different_account_params))
  end

  def valid_account_params(different_account_params: {})
    { org_name: 'Alaska', vat_rate: 33 }.merge(different_account_params)
  end

  def valid_user_params(different_user_params: {})
    { email: 'emailTest@email.com', username: 'john', first_name: 'John', last_name: 'Doe',
      password: '123456', password_confirmation: '123456', signup_type: :minimal }.merge(different_user_params)
  end
end
