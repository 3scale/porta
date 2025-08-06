# frozen_string_literal: true

Recaptcha.configure do |config|
  # Do not verify recaptcha keys if it is not correctly configured
  (config.skip_verify_env ||= []) << Rails.env if Rails.configuration.three_scale.recaptcha_public_key.blank?
  config.site_key = Rails.configuration.three_scale.recaptcha_public_key
  config.secret_key = Rails.configuration.three_scale.recaptcha_private_key
  config.enterprise = Rails.configuration.three_scale.recaptcha_enterprise_enabled
  config.enterprise_api_key = Rails.configuration.three_scale.recaptcha_enterprise_api_key
  config.enterprise_project_id = Rails.configuration.three_scale.recaptcha_enterprise_project_id
end

module Recaptcha
  def self.captcha_configured?
    !Recaptcha.skip_env?(Rails.env)
  end
end
