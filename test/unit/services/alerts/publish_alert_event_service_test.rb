require 'test_helper'

class Alerts::PublishAlertEventServiceTest < ActiveSupport::TestCase

  def setup
    @account   = FactoryGirl.create(:buyer_account)
    @cinstance = FactoryGirl.create(:cinstance, user_account: @account)
  end

  def test_run_alert_for_provider
    alert = FactoryGirl.create(:limit_alert)

    Alerts::LimitAlertReachedProviderEvent.expects(:create).once

    assert Alerts::PublishAlertEventService.run! alert
  end

  def test_run_alert_for_buyer
    alert = FactoryGirl.create(:limit_alert, account: @account,
                                 cinstance: @cinstance)

    Alerts::LimitAlertReachedBuyerEvent.expects(:create).once

    assert Alerts::PublishAlertEventService.run! alert
  end

  def test_run_violation_for_provider
    alert = FactoryGirl.create(:limit_violation)

    Alerts::LimitViolationReachedProviderEvent.expects(:create).once

    assert Alerts::PublishAlertEventService.run! alert
  end

  def test_run_violation_for_buyer
    alert = FactoryGirl.create(:limit_violation, account: @account,
                                 cinstance: @cinstance)

    Alerts::LimitViolationReachedBuyerEvent.expects(:create).once

    assert Alerts::PublishAlertEventService.run! alert
  end
end
