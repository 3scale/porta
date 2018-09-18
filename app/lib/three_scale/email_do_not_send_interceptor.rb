class ThreeScale::EmailDoNotSendInterceptor

  def self.delivering_email(message)
    if message.header[::Message::DO_NOT_SEND_HEADER]
      message.perform_deliveries = false
      Rails.logger.info "--> #{::Message::DO_NOT_SEND_HEADER} header present; cancelling email #{message.subject} to #{message.to}."
    end
  end
end
