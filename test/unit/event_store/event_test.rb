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

  class EventRollbacksTest < ActiveSupport::TestCase

    class EventWithCallbacks < EventStore::Event
      after_rollback :after_rollback_method

      def after_rollback_method; end
    end

    test 'rolledback harmless exceptions not reported' do
      System::ErrorReporting.expects(:report_error).with(instance_of(EventStore::Event::EventRollbackError)).never

      ActiveRecord::Base.transaction do
        EventStore::Event.create!(stream: 'dummy', event_type: 'Dummy', event_id: 1, provider_id: 1, data: { whatever: 1 })
        raise ActiveRecord::Rollback
      end
    end

    test 'failed rolledback with transactional callbacks' do
      EventWithCallbacks.expects(:after_rollback_method).never
      System::ErrorReporting.expects(:report_error).with(instance_of(EventStore::Event::EventRollbackError))

      ActiveRecord::Base.transaction do
        EventWithCallbacks.create!(stream: 'dummy', event_type: 'Dummy', event_id: 1, provider_id: 1, data: { whatever: 1 })
        ActiveJob::Arguments.stubs(:deserialize).raises(ActiveRecord::RecordNotFound)
        raise ActiveRecord::Rollback
      end
    end

    test 'successful rolledback with transactional callbacks' do
      EventWithCallbacks.any_instance.expects(:after_rollback_method)

      ActiveRecord::Base.transaction do
        EventWithCallbacks.create!(stream: 'dummy', event_type: 'Dummy', event_id: 1, provider_id: 1, data: { whatever: 1 })
        raise ActiveRecord::Rollback
      end
    end
  end
end
