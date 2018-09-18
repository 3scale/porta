require 'test_helper'

class NotificationDeliveryServiceTest < ActiveSupport::TestCase

  def test_call
    notification = FactoryGirl.build_stubbed(:notification_with_parent_event, system_name: :application_created)
    service      = NotificationDeliveryService.new(notification)

    mail = mock('message')

    NotificationMailer
      .expects(:application_created).with(notification.parent_event, notification.user)
      .returns(mail)

    value = Object.new
    mail.expects(:deliver).returns(value)

    assert_equal value, service.call
  end

  def test_missing_notification_event
    notification = FactoryGirl.build_stubbed(:notification)
    service      = NotificationDeliveryService.new(notification)

    assert_raise NotificationDeliveryService::MissingEntityError do
      service.call
    end
  end

  def test_invalid_event
    event_data   = { provider: '', user: FactoryGirl.create(:simple_user) }
    event        = FactoryGirl.build_stubbed(:event, data: event_data)
    notification = FactoryGirl.build_stubbed(:notification)
    notification.expects(:parent_event).returns(event)

    assert_raise NotificationDeliveryService::InvalidEventError do
      NotificationDeliveryService.new(notification).call
    end
  end
end
