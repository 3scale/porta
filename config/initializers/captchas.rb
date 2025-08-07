# frozen_string_literal: true

Recaptcha.configure do |config|
  # Do not verify recaptcha keys if it is not correctly configured
  (config.skip_verify_env ||= []) << Rails.env if Rails.configuration.three_scale.recaptcha_public_key.blank?

  config.enterprise = Rails.configuration.three_scale.recaptcha_project_id.present?
  config.site_key = Rails.configuration.three_scale.recaptcha_public_key

  if config.enterprise
    config.enterprise_api_key = Rails.configuration.three_scale.recaptcha_private_key
    config.enterprise_project_id = Rails.configuration.three_scale.recaptcha_project_id
  else
    config.secret_key = Rails.configuration.three_scale.recaptcha_private_key
  end
end

module Recaptcha
  def self.captcha_configured?
    !Recaptcha.skip_env?(Rails.env)
  end
end
