require 'test_helper'

class EventStore::EventTest < ActiveSupport::TestCase

  def test_serialization_event_error
    ActiveJob::Arguments.expects(:serialize).raises(URI::InvalidURIError).twice

    event = EventStore::Event.new(
      stream:     'dummie',
      event_type: 'Dummie',
      event_id:   1,
      metadata: { provider_id: 1 }
    )

    assert_raise(EventStore::Event::WithGlobalId::SerializationEventError) do
      event.data = { key: 'value' }
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
    Timecop.freeze(EventStore::Event::TTL.ago)
    FactoryBot.create(:service_token)
    events_number = EventStore::Event.count
    assert events_number.positive?

    Timecop.return
    FactoryBot.create(:service_token)
    assert EventStore::Event.count > events_number

    assert_equal events_number, EventStore::Event.stale.count
  end
end
