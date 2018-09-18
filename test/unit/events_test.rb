# frozen_string_literal: true

require 'test_helper'

class EventsTest < ActiveSupport::TestCase
  test '#async_fetch_backend_events' do
    EventsFetchWorker.expects(:enqueue).returns(true)
    Events.async_fetch_backend_events!
  end

  test '#fetch_backend_events' do
    timestamp = Time.now.iso8601
    one = ThreeScale::Core::Event.new({ type: 'one', id: 1, timestamp: timestamp })
    two = ThreeScale::Core::Event.new({ type: 'two', id: 2, timestamp: timestamp })

    Events::Importer.expects(:clear_services_cache)
    PersistEventWorker.expects(:enqueue).with(one.attributes)
    PersistEventWorker.expects(:enqueue).with(two.attributes)
    Events.expects(:delete_events_from_backend_until!).with(2)

    Events.fetch_backend_events! [one, two]
  end

  test 'delete_events_from_backend_until' do
    ThreeScale::Core::Event.expects(:delete_upto).with(42)
    Events.delete_events_from_backend_until!(42)
  end
end
