require 'test_helper'

class NotificationEventTest < ActiveSupport::TestCase
  def test_create
    provider = FactoryBot.build_stubbed(:simple_provider, id: 42)
    other_event = Class.new(RailsEventStore::Event).new(provider: provider)

    notification_event = NotificationEvent.create(:some_name, other_event)

    assert notification_event

    assert_equal 'some_name', notification_event.system_name
    assert_equal other_event.event_id, notification_event.parent_event_id
    assert_equal provider.id, notification_event.provider_id
  end


  def test_after_commit
    event = NotificationEvent.new

    assert_difference ProcessNotificationEventWorker.jobs.method(:size) do
      event.after_commit
    end

    job = ProcessNotificationEventWorker.jobs.last

    assert_equal [event.event_id], job['args']
  end
end
