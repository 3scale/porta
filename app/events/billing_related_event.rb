class BillingRelatedEvent < BaseEventStoreEvent
  # use only if event is related to billing/finance

  # billing related event notification is being send
  # when user has permission to "finance"

  self.category = :billing
end
