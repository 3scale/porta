class Messages::MessageReceivedEvent < AccountRelatedEvent
  def self.create(message, recipient)
    service_ids = message.sender.buyer? ? message.sender.bought_service_contracts.accessible_services.pluck(:id) : []

    new(
      message:   message,
      sender:    message.sender,
      recipient: recipient,
      receiver:  recipient.receiver,
      provider:  recipient.receiver,
      service_ids:,
      metadata: {
        provider_id: recipient.receiver_id
      }
    )
  end
end
