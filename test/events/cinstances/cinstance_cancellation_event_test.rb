require 'test_helper'

class Cinstances::CinstanceCancellationEventTest < ActiveSupport::TestCase

  def test_create
    service   = FactoryGirl.build_stubbed(:simple_service, id: 2)
    plan      = FactoryGirl.build_stubbed(:simple_application_plan, id: 3, issuer: service)
    cinstance = FactoryGirl.build_stubbed(:simple_cinstance, id: 1, plan: plan)
    event     = Cinstances::CinstanceCancellationEvent.create(cinstance)

    assert event
    assert_equal event.cinstance_name, cinstance.name
    assert_equal event.plan_name, plan.name
    assert_equal event.service_name, service.name
    assert_equal event.provider, cinstance.provider_account
    assert_equal event.service, cinstance.service
  end

  def test_valid?
    service   = FactoryGirl.build_stubbed(:simple_service, id: 2)
    plan      = FactoryGirl.build_stubbed(:simple_application_plan, id: 3, issuer: service)
    cinstance = FactoryGirl.build_stubbed(:simple_cinstance, id: 1, plan: plan)

    assert Cinstances::CinstanceCancellationEvent.valid?(cinstance)

    cinstance.expects(:issuer).returns(nil)
    refute Cinstances::CinstanceCancellationEvent.valid?(cinstance)
  end

  def test_create_and_publish
    service   = FactoryGirl.build_stubbed(:simple_service, id: 2)
    plan      = FactoryGirl.build_stubbed(:simple_application_plan, id: 3, issuer: service)
    cinstance = FactoryGirl.build_stubbed(:simple_cinstance, id: 1, plan: plan)

    Cinstances::CinstanceCancellationEvent.expects(:create).once
    Cinstances::CinstanceCancellationEvent.create_and_publish!(cinstance)

    cinstance.expects(:issuer).returns(nil)
    Cinstances::CinstanceCancellationEvent.expects(:create).never
    Cinstances::CinstanceCancellationEvent.create_and_publish!(cinstance)
  end
end
