require 'test_helper'

class Applications::ApplicationPlanChangeRequestedEventTest < ActiveSupport::TestCase

  def test_case
    provider    = FactoryGirl.build_stubbed(:simple_provider, id: 3)
    account     = FactoryGirl.build_stubbed(:simple_buyer, id: 4, name: 'Boo Account', provider_account: provider)
    service     = FactoryGirl.build_stubbed(:simple_service, account: provider)
    plan        = FactoryGirl.build_stubbed(:simple_application_plan, id: 1, issuer: service)
    plan_2      = FactoryGirl.build_stubbed(:simple_application_plan, id: 2, issuer: service)
    user        = FactoryGirl.build_stubbed(:simple_user, account: account)
    application = FactoryGirl.build_stubbed(:simple_cinstance, plan: plan, user_account: account, service: service)

    event = Applications::ApplicationPlanChangeRequestedEvent.create(application, user, plan_2)

    assert event
    assert_equal account, event.account
    assert_equal user, event.user
    assert_equal plan_2, event.requested_plan
    assert_equal plan, event.current_plan
  end
end
