module MessagesHelper
  # Format name of message receiver(s). Do not display each recipient's name, if there
  # are multiple
  def message_receiver(message)
    if message.recipients.count > 1
      "Multiple Recipients"
    else
      receiver = message.recipients.first.try!(:receiver)
      (receiver.nil? || receiver.buyer?) ? link_to_buyer_or_deleted(receiver) : receiver.org_name
    end
  end

  def message_sender(message)
    sender = message.sender
    (sender.nil? || sender.buyer?) ? link_to_buyer_or_deleted(sender) : sender.org_name
  end

  def message_subject(message)
    return message.subject if message.subject.present?
    return truncate(message.body, :length => 15) if message.body.present?

    '(No subject)'
  end

  def hyperlink_urls(text)
    text = h(text)

    text.scan(URI.regexp(%w(http https))) do
      #$& contains the whole match of the regural expression
      url = $&.sub(/\.$/, '').sub(/\:$/,'')
      text = text.sub(url, link_to(url, url))
    end

    text.html_safe
  end

end
