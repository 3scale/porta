class ThreeScale::EmailConfigurationInterceptor
  def self.delivering_email(message)
    found_mapping = find_mapping
    return unless found_mapping

    message.delivery_method.settings = found_mapping.mailer_settings
  end

  def self.find_mapping
    from = message.from.first
    return unless from

    # If we allow each provider to set their own mapping, then
    # account.email_configurations.find_by(email: from)
    EmailConfiguration.find_by(email: from)
  end
end

