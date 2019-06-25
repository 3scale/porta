# frozen_string_literal: true

class EventStore::Services::ServiceDeletedEvent < EventStore::Event
  default_scope -> { where(event_type: ::Services::ServiceDeletedEvent) }

  scope :by_service_id, lambda { |service_id|
    concat_query = if System::Database.oracle?
                     "('%service_id: ' || #{service_id} || '%')"
                   else
                     "CONCAT('%service_id: ',  #{service_id}, '%')"
                   end
    where("data LIKE #{concat_query}")
  }
end
