class AccountRelatedEvent < BaseEventStoreEvent
  # use only if event is related to account/partners

  # account related event notification is being send
  # when user has permission to "partners"

  self.category = :account
end
