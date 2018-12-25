class EventStore::RepositoryTest < ActiveSupport::TestCase
  include EventStore

  class DummyEvent < RailsEventStore::Event
    def self.create(dummy, provider = nil)
      new(
        name:     dummy.name,
        provider: provider,
        metadata: {
          provider_id: provider.try!(:id)
        }
      )
    end
  end

  class DummieSubscriber
    def call(event)
      event
    end
  end

  def test_initialize
    assert Repository.new
  end

  def test_publish_event
    assert Repository.new.publish_event(dummie_event)
  end

  def test_active_record_store
    store = Repository.new(RailsEventStoreActiveRecord::EventRepository.new)

    assert_difference(RailsEventStoreActiveRecord::Event.where(
      event_type: 'EventStore::RepositoryTest::DummyEvent').method(:count), +1) do

      store.publish_event(dummie_event)
    end
  end

  def test_find_event
    repository = RailsEventStoreActiveRecord::EventRepository.new

    event_data = repository.adapter.create!(stream: 'foo', event_type: RailsEventStore::Event,
                                            event_id: SecureRandom.uuid, data: {}, metadata: {})

    assert event = Repository.find_event(event_data.event_id)
    assert_equal event_data.event_id, event.event_id

    assert_nil Repository.find_event('unknown')
  end

  def test_find_event!
    repository = RailsEventStoreActiveRecord::EventRepository.new

    event_data = repository.adapter.create!(stream: 'foo', event_type: RailsEventStore::Event,
                                            event_id: SecureRandom.uuid, data: {}, metadata: {})

    assert event = Repository.find_event!(event_data.event_id)
    assert_equal event_data.event_id, event.event_id

    assert_raise ActiveRecord::RecordNotFound do
      Repository.find_event!('unknown')
    end
  end

  def test_build_entity
    event = FactoryBot.build(:event, data: { foo: 'bar' })

    assert entity = Repository.build_entity(event)
    assert_equal event.event_id, entity.event_id
    assert_equal 'bar', entity.foo
  end

  def test_serialization
    account, user = nil

    # TODO
    # better way to solve this?
    # factory girl should not call observer callbacks!
    Account.observers.disable :all do
      provider = FactoryBot.create(:simple_provider)
      account  = FactoryBot.create(:simple_buyer, provider_account: provider)
      user     = FactoryBot.create(:simple_user)
    end

    event      = Accounts::AccountCreatedEvent.create(account, user)
    repository = EventStore::Repository.new(EventStore::Repository.repository)

    assert_difference EventStore::Repository.adapter
      .where(event_type: 'Accounts::AccountCreatedEvent').method(:count), +1 do
      repository.publish_event(event)
    end
  end

  def test_handle_invalid_event
    repository = Repository.new
    subscriber = DummieSubscriber.new

    repository.subscribe_to_all_events(subscriber)

    # event is invalid, callbacks should not be called
    subscriber.expects(:call).never

    # it should notify bugsnag
    Bugsnag.expects(:notify).once

    refute repository.publish_event(invalid_dummie_event)
  end

  def test_handle_valid_event
    repository = Repository.new
    subscriber = DummieSubscriber.new

    repository.subscribe_to_all_events(subscriber)

    # event is valid, callbacks should be called
    subscriber.expects(:call).once

    assert repository.publish_event(dummie_event)
  end

  private

  def simple_dummie_event
    @dummie_event ||= DummyEvent.create(OpenStruct.new(name: 'Otto'))
  end

  alias invalid_dummie_event simple_dummie_event

  def dummie_event
    @dummie_event ||= DummyEvent.create(OpenStruct.new(name: 'Otto'), provider)
  end

  def provider
    @provider ||= FactoryBot.create(:simple_provider)
  end
end
