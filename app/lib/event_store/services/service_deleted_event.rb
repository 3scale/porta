# frozen_string_literal: true

class EventStore::Services::ServiceDeletedEvent < EventStore::Event
  default_scope -> { where(event_type: ::Services::ServiceDeletedEvent) }

  scope :by_object_id, ->(service_id) { where("data LIKE ('%\nservice_id: #{service_id}\n%')") }
end
