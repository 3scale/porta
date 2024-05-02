require 'test_helper'

class EventStore::EventTest < ActiveSupport::TestCase

  def test_serialization_event_error
    ActiveJob::Arguments.stubs(:serialize).raises(URI::InvalidURIError)

    event = EventStore::Event.new(
      stream:     'dummie',
      event_type: 'Dummie',
      event_id:   1,
      metadata: { provider_id: 1 }
    )

    assert_raise(EventStore::Event::WithGlobalId::SerializationEventError) do
      event.data = { key: 'value' }
      event.save
    end
  end

  def test_provider_id_from_metadata
    provider = FactoryBot.create :simple_provider

    event = EventStore::Event.new(
      stream:     'dummie',
      event_type: 'Dummie',
      event_id:   1,
      metadata: { provider_id: provider.id }
    )

    event.save

    assert_equal event.provider_id, provider.id
  end

  def test_provider
    provider = FactoryBot.create(:simple_provider)
    event    = EventStore::Event.new(
      stream:     'dummie',
      event_type: 'Dummie',
      event_id:   1,
      metadata: { provider_id: provider.id }
    )

    event.save

    assert_equal event.provider.id, provider.id
  end

  def test_valid?
    event = EventStore::Event.new(
      stream:     'dummie',
      event_type: 'Dummie',
      event_id:   1
    )

    refute event.valid?

    event.metadata = { provider_id: 2 }

    assert event.valid?
  end

  def test_not_utf8_data
    provider = FactoryBot.create(:simple_provider)
    event    = EventStore::Event.new(
      stream:      'dummie',
      event_type:  'Dummie',
      event_id:    1,
      provider_id: provider.id,
      data: {
        name: 'Alexander 百鬼斬 Supetramp'
      }
    )

    assert event.save!
  end

  def test_stale
    travel_to((EventStore::Event::TTL + 1.second).ago) do
      FactoryBot.create(:service_token)
    end

    FactoryBot.create(:service_token)

    expected_stale_events_count = EventStore::Event.where('created_at <= ?', EventStore::Event::TTL.ago).count
    assert_equal expected_stale_events_count, EventStore::Event.stale.count
  end

  def test_rolledback_harmless_exceptions_not_reported
    event = EventStore::Event.create!(stream: 'dummy', event_type: 'Dummy', event_id: 1, provider_id: 1, data: { whatever: 1 })

    ActiveJob::Arguments.stubs(:deserialize).raises(ActiveRecord::RecordNotFound)
    System::ErrorReporting.expects(:report_error).with(instance_of(EventStore::Event::EventRollbackError)).never

    event.rolledback!
  end

  class EventWithCallbacks < EventStore::Event
    after_rollback :a_callback_method

    def a_callback_method
    end
  end

  def test_failed_rolledback_with_transactional_callbacks
    event = EventWithCallbacks.create!(stream: 'dummy', event_type: 'Dummy', event_id: 1, provider_id: 1, data: { whatever: 1 })

    ActiveJob::Arguments.stubs(:deserialize).raises(ActiveRecord::RecordNotFound)
    EventWithCallbacks.expects(:a_callback_method).never
    System::ErrorReporting.expects(:report_error).with(instance_of(EventStore::Event::EventRollbackError))

    event.rolledback!
  end

  def test_successful_rolledback_with_transactional_callbacks
    EventWithCallbacks.any_instance.expects(:a_callback_method)

    ActiveRecord::Base.transaction do
      EventWithCallbacks.create!(stream: 'dummy', event_type: 'Dummy', event_id: 1, provider_id: 1, data: { whatever: 1 })
      raise ActiveRecord::Rollback
    end
  end
end
