# frozen_string_literal: true

require 'three_scale/settings'

ThreeScale::Settings.configure('payments.enabled') do
  case Rails.env
  when 'production', 'test'
    true
  when 'development'
    ENV.fetch('THREESCALE_PAYMENTS_ENABLED', '0') == '1'
  end
end

ThreeScale::Settings.configure('payments.active_merchant_mode') do
  case Rails.env
  when 'test'
    :test
  else
    Rails.application.config.three_scale.try(:active_merchant_mode)&.to_sym || (Rails.env.production? ? :production : :test)
  end
end

ThreeScale::Settings.configure('payments.active_merchant_logging') do
  case Rails.env
  when 'test'
    false
  else
    Rails.application.config.three_scale.try(:active_merchant_logging)
  end
end

ThreeScale::Settings.configure('payments.billing_canaries') { Rails.application.config.three_scale.try(:billing_canaries) }

ThreeScale::Settings.merge!((Rails.application.try_config_for(:payments) || {}).transform_keys { |key| "payments.#{key}" })

require 'active_merchant_hacks'

ActiveMerchant::Billing::Base.mode = ThreeScale::Settings.get('payments.active_merchant_mode')
Rails.logger.info("ActiveMerchant MODE set to '#{ActiveMerchant::Billing::Base.mode}'")

if ThreeScale::Settings.get('payments.active_merchant_logging')
  ActiveMerchant::Billing::Gateway.wiredump_device = Rails.root.join('log/activemerchant.log').open('a')
  ActiveMerchant::Billing::Gateway.wiredump_device.sync = true
end

ActiveMerchant::Billing::StripeGateway.prepend(Module.new do
  def headers(options = {})
    key = options[:key] || @api_key
    idempotency_key = options[:idempotency_key]

    headers = {
      'Authorization' => 'Basic ' + Base64.encode64(key.to_s + ':').strip.delete("\n"),
      'User-Agent' => "Stripe/v1 ActiveMerchantBindings/#{ActiveMerchant::VERSION}",
      'Stripe-Version' => api_version(options),
      'X-Stripe-Client-User-Agent' => stripe_client_user_agent(options),
      'X-Stripe-Client-User-Metadata' => {ip: options[:ip]}.to_json
    }
    headers['Idempotency-Key'] = idempotency_key if idempotency_key
    headers['Stripe-Account'] = options[:stripe_account] if options[:stripe_account]
    headers
  end
end)
