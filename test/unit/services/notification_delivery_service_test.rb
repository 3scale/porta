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

  def test_nil_is_invalid_event
    event_data   = { provider: nil, user: FactoryGirl.create(:simple_user) }
    event        = FactoryGirl.build_stubbed(:event, data: event_data)
    notification = FactoryGirl.build_stubbed(:notification)
    notification.expects(:parent_event).returns(event)

    assert_raise NotificationDeliveryService::InvalidEventError do
      NotificationDeliveryService.new(notification).call
    end
  end

  def test_false_boolean_attribute_is_valid_event
    account = FactoryGirl.create(:simple_provider, buyer: false)
    FactoryGirl.create(:active_admin, account: account)
    event = Accounts::AccountDeletedEvent.create(account)
    notification = FactoryGirl.build_stubbed(:notification, system_name: :account_deleted)
    notification.expects(:parent_event).returns(event)

    NotificationDeliveryService.new(notification).call
  end

  def test_empty_attribute_is_a_valid_event
    ['', []].each do |empty_value|
      service = FactoryGirl.build_stubbed(:simple_service, name: empty_value)
      event = Services::ServiceDeletedEvent.create(service)
      notification = FactoryGirl.build_stubbed(:notification, system_name: :service_deleted)
      notification.expects(:parent_event).returns(event)

      NotificationDeliveryService.new(notification).call
    end
  end
end
