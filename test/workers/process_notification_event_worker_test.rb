require 'test_helper'

class ProcessNotificationEventWorkerTest < ActiveSupport::TestCase

  CustomEvent = Class.new(RailsEventStore::Event)

  def setup
    @worker = ProcessNotificationEventWorker.new
  end

  def test_perform
    skip
  end

  def test_enqueue
    event = NotificationEvent.new
    assert ProcessNotificationEventWorker.enqueue(event)
  end

  def test_create_notifications
    provider     = FactoryBot.create(:simple_provider)
    event        = Invoices::InvoicesToReviewEvent.create(provider)
    notification = NotificationEvent.create(:invoices_to_review, event)
    user         = FactoryBot.create(:simple_admin, account: provider)

    user.create_notification_preferences!(preferences: { invoices_to_review: true })

    Rails.application.config.event_store.publish_event(event)
    Rails.application.config.event_store.publish_event(notification)

    Sidekiq::Testing.inline! do
      assert_difference Notification.method(:count) do
        NotificationDeliveryService.expects(:call).with(instance_of(Notification))
        @worker.create_notifications(notification)
      end
    end
  end

  def test_create_notifications_with_master
    event  = CustomEvent.new(provider: master_account)
    notification = NotificationEvent.create(:application_created, event)

    assert_equal master_account, @worker.create_notifications(notification)
  end

  def test_skip_notifications_for_suspended_account
    provider = FactoryBot.create(:simple_provider, state: 'suspended')
    event  = CustomEvent.new(provider: provider)
    notification = NotificationEvent.create(:application_created, event)

    ProcessNotificationEventWorker::UserNotificationWorker.expects(:perform_async).never

    refute @worker.create_notifications(notification)
  end

  def test_rescue_errors
    provider     = FactoryBot.create(:simple_provider)
    event        = Invoices::InvoicesToReviewEvent.create(provider)
    notification = NotificationEvent.create(:invoices_to_review, event)
    user         = FactoryBot.create(:simple_admin, account: provider)

    user.create_notification_preferences!(preferences: { invoices_to_review: true })

    Rails.application.config.event_store.publish_event(event)
    Rails.application.config.event_store.publish_event(notification)

    Notification.any_instance.stubs(:deliver!).raises(
      ::NotificationDeliveryService::InvalidEventError.new(event))

    Sidekiq::Testing.inline! do
      assert @worker.create_notifications(notification)
    end
  end
end
