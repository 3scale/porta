# frozen_string_literal: true

require 'test_helper'

class Logic::ProviderSignupTest < ActiveSupport::TestCase
  class SampleDataTest < Logic::ProviderSignupTest
    def setup
      @provider = FactoryBot.create(:provider_account)
    end

    test 'John Doe user is created with a strong derived password' do
      sample_data = Logic::ProviderSignup::SampleData.new(@provider)
      sample_data.create!

      john_doe = @provider.buyer_users.find_by(username: 'john')
      assert john_doe.present?, 'John Doe user should be created'
      assert john_doe.authenticate(Logic::SampleDeveloperPassword.for(@provider)), 'John Doe should authenticate with the derived password'
    end

    test 'John Doe is not created with the old weak password 123456' do
      sample_data = Logic::ProviderSignup::SampleData.new(@provider)
      sample_data.create!

      john_doe = @provider.buyer_users.find_by(username: 'john')
      assert_not john_doe.authenticate('123456'), 'John Doe should not authenticate with 123456'
    end

    test 'John Doe uses minimal signup type' do
      sample_data = Logic::ProviderSignup::SampleData.new(@provider)
      sample_data.create!

      john_doe = @provider.buyer_users.find_by(username: 'john')
      assert john_doe.signup.minimal?, 'John Doe should have minimal signup type'
    end

    test 'John Doe is active after creation' do
      sample_data = Logic::ProviderSignup::SampleData.new(@provider)
      sample_data.create!

      john_doe = @provider.buyer_users.find_by(username: 'john')
      assert john_doe.active?, 'John Doe should be active after creation'
    end
  end

  class MasterTest < Logic::ProviderSignupTest
    setup do
      @master = FactoryBot.build_stubbed(:simple_master)
      Account.stubs(:master).returns(@master)
    end

    test 'provider_signup_form_enabled? returns false when provider_signup_form_enabled is false regardless of plans' do
      ThreeScale.config.stubs(provider_signup_form_enabled: false)
      stub_plans_present
      assert_not @master.provider_signup_form_enabled?
    end

    test 'provider_signup_form_enabled? returns true when provider_signup_form_enabled is true and all required plans exist' do
      ThreeScale.config.stubs(provider_signup_form_enabled: true)
      stub_plans_present
      assert @master.provider_signup_form_enabled?
    end

    test 'provider_signup_form_enabled? returns false when provider_signup_form_enabled is true but required plans are missing' do
      ThreeScale.config.stubs(provider_signup_form_enabled: true)
      stub_plans_missing
      assert_not @master.provider_signup_form_enabled?
    end

    private

    def stub_plans_present
      service = stub('service', service_plans: stub('service_plans', default: stub('service_plan')))
      @master.stubs(:services).returns(stub('services', default: service))
      @master.stubs(:account_plans).returns(stub('account_plans', default: stub('account_plan')))
    end

    def stub_plans_missing
      @master.stubs(:services).returns(stub('services', default: nil))
      @master.stubs(:account_plans).returns(stub('account_plans', default: nil))
    end
  end
end
