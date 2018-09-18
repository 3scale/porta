require 'test_helper'

class Alerts::LimitViolationReachedProviderEventTest < ActiveSupport::TestCase

  def test_create
    cinstance = FactoryGirl.build_stubbed(:simple_cinstance)
    cinstance.stubs(:provider_account_id).returns(10)
    cinstance = FactoryGirl.build_stubbed(:simple_cinstance)
    alert     = FactoryGirl.build_stubbed(:limit_violation, id: 2, cinstance: cinstance)
    event     = Alerts::LimitViolationReachedProviderEvent.create(alert)

    assert event
    assert_equal event.alert, alert
    assert_equal event.provider, cinstance.provider_account
  end
end
