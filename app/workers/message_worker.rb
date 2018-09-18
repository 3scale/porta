class MessageWorker
  include Sidekiq::Worker

  def self.enqueue(recipients, attributes)
    perform_async(recipients.as_json, attributes.as_json)
  end

  def perform(recipients, attributes)
    message = Message.new(attributes)
    message.sender_id = attributes["sender_id"]

    # ATTENTION:
    #
    # Trick to skip large transactions
    # when saving a message with a big amount of recipients.
    #
    # 1. Save the message
    # 2. Assign the recipients in memory
    # 3. Update the recipients, create and destroy MessageRecipients.
    # 4. Deliver!
    begin
      message.save!
      recipients.each do |kind, ids|
        accounts = Account.where(id: ids)
        message.send(kind, accounts)
      end

      message.update_recipients
    rescue
      MessageRecipient.where(message_id: message.id).destroy_all if message.id
      message.destroy
      raise
    end

    message.deliver!
  end
end
