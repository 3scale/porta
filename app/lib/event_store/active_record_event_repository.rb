# frozen_string_literal: true

module EventStore
  class ActiveRecordEventRepository < RailsEventStoreActiveRecord::EventRepository
    def build_event_entity(record)
      return nil unless record

      data = record.data.merge(
        event_id: record.event_id,
        metadata: record.metadata
      )
      # Adding double splat for Ruby 3.0 compatibility
      record.event_type.constantize.new(**data)
    end
  end
end
