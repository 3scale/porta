# frozen_string_literal: true

require 'test_helper'

module Signup
  class AccountManagerTest < ActiveSupport::TestCase

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
        assert_equal "#{org_name_param_downcase}-admin.#{ThreeScale.config.superdomain}", account.internal_admin_domain

        # the main user has the right attributes
        valid_user_params.each do |user_attribute_name, expected_user_attribute_value|
          assert_equal expected_user_attribute_value, user.send(user_attribute_name)
        end
        assert_equal :admin, user.role

        # impersonation_admin user is also created with the right attributes
        assert_equal "#{ThreeScale.config.impersonation_admin[:username]}+#{account.internal_domain}@#{imp_config[:domain]}", impersonation_user.email
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
        check_events_validity!(type: Accounts::AccountCreatedEvent.to_s, count: 1)
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
        account.settings.switches.each { |_name, switch| assert switch.allowed? }

        # Saas
        ThreeScale.config.stubs(onpremises: false)
        signup_result    = signup_account_manager.create(signup_params)
        account          = signup_result.account
        # account has the right plans
        assert_equal account_plan, account.bought_account_plan
        assert_equal [service_plan], account.bought_service_plans
        assert_equal [application_plan], account.bought_application_plans
        # should set the switches to nothing is allowed (because the enterprise plan for saas is not automatically validated)
        account.settings.switches.each { |_name, switch| refute switch.allowed? }
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

      test 'first service has a complete backend api' do
        account = signup_account_manager.create(signup_params).account
        assert_equal 1, account.backend_apis.count
        assert (service = account.default_service)
        assert_equal 1, service.backend_apis.count
        assert (backend_api = service.backend_apis.accessible.first)
        assert_equal BackendApi.default_api_backend, backend_api.private_endpoint
        assert_equal service.system_name, backend_api.system_name
        assert_equal "#{service.name} Backend", backend_api.name
        assert_equal "Backend of #{service.name}", backend_api.description
        assert_equal service.account_id, backend_api.account_id
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
        check_events_validity!(type: Accounts::AccountCreatedEvent.to_s, count: 1)
        check_events_validity!(type: Applications::ApplicationCreatedEvent.to_s, count: 1, opts: {provider_id: manager_account.id})
        check_events_validity!(type: ServiceContracts::ServiceContractCreatedEvent.to_s, count: 1, opts: {provider_id: manager_account.id})
      end

      test 'create developer without account plan approval required and minimal signup' do
        @account_plan.update_attribute(:approval_required, false)
        signup_result = signup_account_manager.create(signup_params(different_user_params: {signup_type: :minimal}))

        # the user is active and the account is approved
        assert signup_result.persisted?
        assert signup_result.user_active?
        assert signup_result.account_approved?
      end

      test 'create developer without account plan approval required and sample_data signup' do
        @account_plan.update_attribute(:approval_required, false)
        signup_result = signup_account_manager.create(signup_params(different_user_params: {signup_type: :sample_data}))

        # the user is active and the account is approved
        assert signup_result.persisted?
        assert signup_result.user_active?
        assert signup_result.account_approved?
      end

      test 'create developer with account plan approval required and minimal signup' do
        # The only difference is result.user_activate_on_minimal_or_sample_data? should return false, and it only happens if the contract_plans goes before this
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
        password: 'superSecret1234#', password_confirmation: 'superSecret1234#', signup_type: :minimal }.merge(different_user_params)
    end
  end
end
