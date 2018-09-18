require 'test_helper'

class Logic::ProviderSignupTest < ActiveSupport::TestCase

  def setup
    @service = master_account.first_service!
  end

  test 'should invoke third_party_notifications!' do
    Account.any_instance.expects(:third_party_notifications!)
    default_signup_provider
  end

  test 'should not invoke third_party_notifications!' do
    Account.any_instance.expects(:third_party_notifications!).never
    default_signup_provider(skip_third_party_notifications: true)
  end

  test 'should set the switches to everything is allowed (because it is enterprise) for on-prem' do
    ThreeScale.config.stubs(onpremises: true)
    enterprise_plan = FactoryGirl.create(:application_plan, system_name: 'enterprise', name: 'enterprise', issuer: @service)
    @service.update_attribute(:default_application_plan, enterprise_plan)
    default_signup_provider.settings.switches.each do |_name, switch|
      assert switch.allowed?
    end
  end

  test 'should not set the switches to allowed for saas' do
    ThreeScale.config.stubs(onpremises: false)
    default_signup_provider.settings.switches.each do |_name, switch|
      refute switch.allowed?
    end
  end

  test 'should set the limits both for on-prem and for saas' do
    [true, false].each do |onpremises|
      ThreeScale.config.stubs(onpremises: onpremises)
      constraints = default_signup_provider.provider_constraints
      assert_nil constraints.max_users
      assert_nil constraints.max_services
      assert constraints.can_create_service?
      assert constraints.can_create_user?
    end
  end

  test 'master with default plans should create new provider' do
    default_signup_provider
    assert @provider.valid?
    assert @user.valid?

    refute @provider.new_record?
    refute @user.new_record?

    assert_equal @provider.id, @provider.reload.tenant_id
    assert_equal @provider.id, @user.reload.tenant_id

    assert_equal @provider.admins.size, 1
    impersonation_admin = @provider.users.admins.impersonation_admin
    assert impersonation_admin.active?
    assert @provider.has_impersonation_admin?
  end

  test 'master with default plans should create sample data' do
    default_signup_provider
    @provider.create_sample_data!
    assert @provider.account_plans.default
    assert_equal 1, @provider.account_plans.count
    service = @provider.first_service!
    assert service
    assert service.service_plans.default
    assert_equal 1, service.service_plans.count
    assert service.application_plans.default
    assert_equal 2, service.application_plans.count
    buyer = @provider.buyers.first
    user = buyer.users.first
    assert_equal 'John', user.first_name
    assert_equal 'Doe', user.last_name
    assert_equal 1, @provider.buyers.size
    assert buyer.approved?
    buyer.users.each do |user|
      assert user.active?
    end
  end

  test 'sample data should be idempotent' do
    provider = default_signup_provider
    provider.create_sample_data!

    refute provider.sample_data

    assert_no_differences models do
      provider.sample_data = true
      provider.create_sample_data!
    end

    refute provider.sample_data
  end


  test 'sample data creates missing models' do
    provider = default_signup_provider
    provider.create_sample_data!

    create_sample_data = Logic::ProviderSignup::SampleData.new(provider).method(:create!)

    assert_difference('AccountPlan.count', -1) { provider.account_plans.each(&:delete) }
    provider.reload
    assert_difference('AccountPlan.count', +1, &create_sample_data)

    assert_difference('Account.count', -1) { provider.buyers.each(&:delete) }
    provider.reload
    assert_difference('Account.count', +1, &create_sample_data)

    assert_difference('ServicePlan.count', -1) { provider.service_plans.each(&:delete) }
    provider.reload
    assert_difference('ServicePlan.count', +1, &create_sample_data)

    assert_difference('ApplicationPlan.count', -2) { provider.application_plans.each(&:delete) }
    provider.reload
    assert_difference('ApplicationPlan.count', +2, &create_sample_data)

    assert_difference('ApiDocs::Service.count', -1) { provider.api_docs_services.each(&:delete) }
    provider.reload
    assert_difference('ApiDocs::Service.count', +1, &create_sample_data)

    assert_difference('Account.count', -1) { provider.buyers.each(&:destroy) }
    provider.reload
    assert_difference('Cinstance.count', +1, &create_sample_data)
  end

  test 'sample data does not change service updated_at' do
    provider = default_signup_provider

    timestamp = 1.year.ago.round

    service = provider.first_service!
    service.update_attributes!(updated_at: timestamp)

    provider.create_sample_data!

    service.reload

    assert_equal timestamp, service.updated_at
  end

  test 'first_admin should be testaccount' do
    default_signup_provider
    assert_equal 'testaccount', @provider.first_admin.username
  end

  test 'account should be classified' do
    ThreeScale::Analytics::UserClassifier.any_instance.stubs(has_3scale_email?: true)
    default_signup_provider do |_provider, user|
      user.email = 'user@example.com'
    end

    assert_equal 'Internal', @provider.extra_fields['account_type']
    refute @provider.billing_monthly?
    refute @provider.paying_monthly?

    ThreeScale::Analytics::UserClassifier.any_instance.stubs(has_3scale_email?: false)
    default_signup_provider do |_provider, user|
      user.email = 'user@example.com'
    end

    assert_equal 'Customer', @provider.extra_fields['account_type']
    assert @provider.billing_monthly?
    assert @provider.paying_monthly?
  end

  test 'enqueues signup job' do
    default_signup_provider do |provider|
      SignupWorker.expects(:enqueue).with(provider)
    end
  end

  private

  def default_signup_provider(options = {})
    signup = master_account.signup_provider(@service.default_application_plan, options) do |provider, user|
      provider.attributes = {
          :org_name => 'Test account',
          :subdomain => 'test', :self_subdomain => 'test-admin'
      }
      user.attributes = {
          :password => 'testtest', :password_confirmation => 'testtest',
          :username => 'testaccount', :email => 'test@example.org'
      }

      yield(provider, user) if block_given?

      @provider, @user = provider, user
    end

    assert signup, 'could not signup provider'

    @provider
  end

  def models
    (ActiveRecord::Base.subclasses - [ RailsEventStoreActiveRecord::Event ]).reject(&:abstract_class?)
  end

  def assert_no_differences(*models, &block)
    # Not calling memo inside the rescue block will break the chain
    # so even though assertion works, it would be running just for portion of models
    # ensuring counter enforces that all models were checked
    counter = 0

    proc = models.flatten.reduce(block) do |memo, model|
      -> do
        begin
          assert_no_difference("#{model}.count", &memo)
         rescue ActiveRecord::StatementInvalid => e
           p e.message
           memo.call
        end

        counter += 1
      end
    end

    proc.call

    assert_equal models.flatten.size, counter
  end
end
