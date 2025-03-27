require 'test_helper'

class Alerts::LimitAlertReachedProviderEventTest < ActiveSupport::TestCase

  def test_create
    cinstance = FactoryBot.build_stubbed(:simple_cinstance)
    cinstance.stubs(:provider_account_id).returns(10)
    alert     = FactoryBot.build_stubbed(:limit_alert, id: 2, cinstance: cinstance)
    event     = Alerts::LimitAlertReachedProviderEvent.create(alert)

    assert event
    assert_equal event.application_id, cinstance.application_id
    assert_equal event.level, alert.level
    assert_equal event.provider, cinstance.provider_account
    assert_equal event.service_id, cinstance.service.id
  end
end
