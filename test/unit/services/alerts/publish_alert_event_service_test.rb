require 'test_helper'

class Alerts::PublishAlertEventServiceTest < ActiveSupport::TestCase

  def setup
    @account   = FactoryBot.create(:buyer_account)
    @cinstance = FactoryBot.create(:cinstance, user_account: @account)
  end

  def test_run_alert_for_provider
    alert = FactoryBot.create(:limit_alert)

    assert_difference(EventStore::Event.where(event_type: 'Alerts::LimitAlertReachedProviderEvent').method(:count)) do
      assert Alerts::PublishAlertEventService.run! alert
    end
  end

  def test_run_alert_for_buyer
    alert = FactoryBot.create(:limit_alert, account: @account, cinstance: @cinstance)

    assert_difference(EventStore::Event.where(event_type: 'Alerts::LimitAlertReachedBuyerEvent').method(:count)) do
      assert Alerts::PublishAlertEventService.run! alert
    end
  end

  def test_run_violation_for_provider
    alert = FactoryBot.create(:limit_violation)

    assert_difference(EventStore::Event.where(event_type: 'Alerts::LimitViolationReachedProviderEvent').method(:count)) do
      assert Alerts::PublishAlertEventService.run! alert
    end
  end

  def test_run_violation_for_buyer
    alert = FactoryBot.create(:limit_violation, account: @account, cinstance: @cinstance)

    assert_difference(EventStore::Event.where(event_type: 'Alerts::LimitViolationReachedBuyerEvent').method(:count)) do
      assert Alerts::PublishAlertEventService.run! alert
    end
  end
end
