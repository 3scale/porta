class ServiceRelatedEvent < BaseEventStoreEvent
  # use only if event is related to service

  # service related event notification is being send
  # when user has permission to the service

  self.category = :service
end
