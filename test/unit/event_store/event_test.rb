require 'test_helper'

class EventStore::EventTest < ActiveSupport::TestCase

  def test_serialization_event_error
    ActiveJob::Arguments.expects(:serialize).raises(URI::InvalidURIError)

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
end
