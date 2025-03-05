class Messages::MessageReceivedEvent < AccountRelatedEvent
  def self.create(message, recipient)
    services = message.sender.buyer? ? message.sender.bought_service_contracts.accessible_services.to_a : []

    new(
      message:   message,
      sender:    message.sender,
      recipient: recipient,
      receiver:  recipient.receiver,
      provider:  recipient.receiver,
      services:,
      metadata: {
        provider_id: recipient.receiver_id
      }
    )
  end
end
