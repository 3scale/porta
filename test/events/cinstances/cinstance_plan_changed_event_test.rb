require 'test_helper'

class Cinstances::CinstancePlanChangedEventTest < ActiveSupport::TestCase

  def test_create
    provider  = FactoryGirl.build_stubbed(:simple_provider, id: 1)
    service   = FactoryGirl.build_stubbed(:simple_service, account: provider)
    plan      = FactoryGirl.build_stubbed(:simple_application_plan, issuer: service)
    cinstance = FactoryGirl.build_stubbed(:cinstance, plan: plan)
    user      = FactoryGirl.build_stubbed(:simple_user)
    event     = Cinstances::CinstancePlanChangedEvent.create(cinstance, user)

    assert event
    assert cinstance, event.cinstance
    assert user, event.user
    assert_equal event.metadata[:provider_id], provider.id
  end
end
