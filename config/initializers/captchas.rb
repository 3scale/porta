# frozen_string_literal: true

Recaptcha.configure do |config|
  # Do not verify recaptcha keys if it is not correctly configured
  (config.skip_verify_env ||= []) << Rails.env if Rails.configuration.three_scale.recaptcha_private_key.blank?
  config.site_key = Rails.configuration.three_scale.recaptcha_public_key
  config.secret_key = Rails.configuration.three_scale.recaptcha_private_key
end

module Recaptcha
  def self.captcha_configured?
    Recaptcha.configuration.skip_verify_env.exclude?(Rails.env)
  end
end
