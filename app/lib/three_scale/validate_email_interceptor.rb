class ThreeScale::ValidateEmailInterceptor

  def self.delivering_email(message)
    return if message.to.present? || message.bcc.present?

    message.perform_deliveries = false
    Rails.logger.info("#{message.subject} email has not been sent, :to or :bcc attribute has to be provided")
  end
end
