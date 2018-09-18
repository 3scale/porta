require 'test_helper'

class Applications::ApplicationCreatedEventTest < ActiveSupport::TestCase

  def test_create
    application = FactoryGirl.build_stubbed(:simple_cinstance, id: 1, service_id: 2,
                    plan: FactoryGirl.build_stubbed(:simple_application_plan, id: 5))
    application.stubs(:provider_account_id).returns(10)
    event       = Applications::ApplicationCreatedEvent.create(application, user)

    assert event
    assert_equal event.application, application
    assert_equal event.provider, application.provider_account
    assert_equal event.service, application.service
    assert_equal event.plan, application.plan
    assert_equal event.user, user
  end

  def test_provider
    # master's service
    master         = FactoryGirl.build_stubbed(:master_account)
    master_service = FactoryGirl.build_stubbed(:service, account: master)
    master_plan    = FactoryGirl.build_stubbed(:simple_application_plan, issuer: master_service)

    master_application = FactoryGirl.build_stubbed(:simple_cinstance, service: master_service, plan: master_plan)
    master_event       = Applications::ApplicationCreatedEvent.create(master_application, user)

    assert_equal master_event.provider, master

    # provider's service
    provider          = FactoryGirl.build_stubbed(:simple_provider, provider_account: master)
    provider_service  = FactoryGirl.build_stubbed(:service, account: provider)
    provider_plan     = FactoryGirl.build_stubbed(:simple_application_plan, issuer: provider_service)

    provider_application = FactoryGirl.build_stubbed(:simple_cinstance, service: provider_service, plan: provider_plan)
    provider_event       = Applications::ApplicationCreatedEvent.create(provider_application, user)

    assert_equal provider_event.provider, provider
  end

  private

  def user
    @_user ||= FactoryGirl.build_stubbed(:simple_user)
  end
end
