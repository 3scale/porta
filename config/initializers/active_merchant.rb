# frozen_string_literal: true

require 'active_merchant_hacks'

ActiveMerchant::Billing::Base.mode = Rails.application.config.three_scale.payments.active_merchant_mode.to_sym
Rails.logger.info("ActiveMerchant MODE set to '#{ActiveMerchant::Billing::Base.mode}'")

if Rails.application.config.three_scale.payments.active_merchant_logging
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
