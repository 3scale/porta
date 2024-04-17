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
  end
end

ActiveSupport::TestCase.class_eval do
  include TestHelpers::Events
end
