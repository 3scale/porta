# frozen_string_literal: true

require 'active_merchant_hacks'

ActiveMerchant::Billing::Base.mode = Rails.application.config.three_scale.active_merchant_mode.to_sym
Rails.logger.info("ActiveMerchant MODE set to '#{ActiveMerchant::Billing::Base.mode}'")

::ActiveMerchant::Billing::Adyen12Gateway.display_name = "Adyen"

if Rails.application.config.three_scale.active_merchant_logging
  ActiveMerchant::Billing::Gateway.wiredump_device = Rails.root.join('log/activemerchant.log').open('a')
  ActiveMerchant::Billing::Gateway.wiredump_device.sync = true
end
