require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  test 'state' do
    notification = FactoryBot.build(:notification, user: FactoryBot.build_stubbed(:user))
    assert_equal 'created', notification.state

    NotificationDeliveryService.expects(:call).with(notification)
    notification.deliver!

    assert_equal 'delivered', notification.state
  end

  test 'readonly' do
    assert_equal Set['event_id', 'user_id', 'system_name'],
                 Notification.readonly_attributes
  end

  test 'deliver_email_notification!' do
    notification = FactoryBot.build_stubbed(:notification, system_name: :application_created)

    NotificationDeliveryService.expects(:call).with(notification)

    notification.deliver_email_notification!
  end

  test 'deliver!' do
    notification = FactoryBot.build_stubbed(:notification)

    NotificationDeliveryService.expects(:call).with(notification)

    notification.fire_events!(:deliver, false)
  end

  test 'should_deliver?' do
    notification = FactoryBot.build_stubbed(:notification_with_parent_event)

    notification.expects(:permitted?).returns(true).at_least_once
    assert notification.should_deliver?

    notification.user.account.expects(:provider_can_use?).with(:new_notification_system).returns(false).at_least_once
    refute notification.should_deliver?

    notification.user.account.expects(:provider_can_use?).with(:new_notification_system).returns(true).at_least_once
    assert notification.should_deliver?

    notification.account.master = true
    ThreeScale.config.stubs(onpremises: true)
    assert notification.should_deliver?

    notification.expects(:hidden_onprem_multitenancy).returns([notification.system_name.to_sym]).at_least_once
    refute notification.should_deliver?
  end

  CustomEvent = Class.new(RailsEventStore::Event)

  test 'event' do
    event = CustomEvent.new(foo: true, bar: false, magic: 42, metadata: { provider_id: master_account.id })
    Rails.application.config.event_store.publish_event(event)

    event = EventStore::Repository.find_event(event.event_id)

    notification = Notification.new(event_id: event.event_id)

    assert_equal event.event_id, notification.event_id
    assert record = notification.event
    assert_equal event.event_id, record.event_id

    assert_equal({ foo: true, bar: false, magic: 42 }, record.data)
  end

  class CustomMailer < ActionMailer::Base
    def custom_notification(event, receiver)
      mail to: 'someone@example.com', subject: event.subject, body: 'some body', from: 'sender@example.com'
    end
  end

  test 'title' do
    notification = Notification.new(system_name: :custom_notification)
    event = CustomEvent.new(subject: 'some subject')
    EventStore::Repository.expects(:find_event).returns(event)
    NotificationDeliveryService.expects(:mailer).returns(CustomMailer)

    notification.deliver_email_notification!

    assert_equal 'some subject', notification.title
  end

  def test_not_utf8_title
    notification = FactoryBot.build(:notification, title: '百鬼斬 HYAKKI GIRI Vögel')

    assert notification.save!
  end
end
