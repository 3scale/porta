# frozen_string_literal: true

require 'test_helper'

class Logic::ProviderSignupTest < ActiveSupport::TestCase
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
