require 'test_helper'
require 'sidekiq/testing'

class ImportEventsFromBackendTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  test "import should delete events from backend, create backend events and call Events::Importer" do
    master_account

    timestamp = Time.now.iso8601
    events    = [
      ThreeScale::Core::Event.new(id: 42, type: 'foo', timestamp: timestamp),
      ThreeScale::Core::Event.new(id: 69, type: 'bar', timestamp: timestamp)
    ]

    Events.expects(:delete_events_from_backend_until!).with(69)
    Events::Importer.expects(:async_import_event!).twice

    Sidekiq::Testing.inline! do
      assert_difference "BackendEvent.count", 2 do
        Events.fetch_backend_events! events
      end
    end
  end
end
