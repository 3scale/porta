# frozen_string_literal: true

class ThreeScale::EmailConfigurationInterceptor
  def self.delivering_email(message)
    return unless Features::EmailConfigurationConfig.enabled?

    found_mapping = find_mapping(message)

    return unless found_mapping

    message.delivery_method.settings = found_mapping.smtp_settings
  end

  def self.find_mapping(message)
    from = message.from&.first
    return unless from

    # If we allow each provider to set their own mapping, then
    # account.email_configurations.find_by(email: from)
    EmailConfiguration.for(from).first
  end
end
