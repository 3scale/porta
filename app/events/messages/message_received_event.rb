class Messages::MessageReceivedEvent < AccountRelatedEvent
  def self.create(message, recipient)
    new(
      message:   message,
      sender:    message.sender,
      recipient: recipient,
      receiver:  recipient.receiver,
      provider:  recipient.receiver,
      metadata: {
        provider_id: recipient.receiver_id
      }
    )
  end
end
