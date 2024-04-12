module TestHelpers
  module Events
    def check_events_validity!(type:, count: 1, opts: {})
      specific_events = EventStore::Repository.adapter.where({event_type: type}.merge(opts))

      specific_events.each do |event|
        event_entity = EventStore::Repository.build_entity(event)

        event_entity.data.each do |key, value|
          assert value.present?, "#{key} is blank"
        end
      end

      assert_equal count.to_i, specific_events.count
    end

    # Since Rails 6.1 the EventStore::Event records (among others) are added to the
    # list of transaction objects, and are rolled back on the transaction rollback.
    # The problem is that this triggers the Event's `load` and `deserialize`, and if
    # the object itself is rolled back first, the deserialization of the related event
    # will fail. This causes some tests (that have explicit transactions and rollbacks) to fail.
    def stub_event_rolledback!
      EventStore::Event.any_instance.stubs(:rolledback!)
    end
  end
end

ActiveSupport::TestCase.class_eval do
  include TestHelpers::Events
end
