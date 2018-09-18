# ActiveMerchant monkey patches

class ActiveMerchant::Billing::Gateway

  # Add threescale-versioned methods for gateways

  def threescale_unstore(identification, *args)
    return nil unless identification.present? && respond_to?(:unstore)

    if System::Application.config.three_scale.payments.enabled
      unstore(identification, *args)
    else
      "Skipping card unstore: Not enabled on this environment"
    end
  end

end

::ActiveMerchant::Billing::AuthorizeNetGateway.class_eval do
  def cim_gateway
    @cim_gateway ||= ::ActiveMerchant::Billing::AuthorizeNetCimGateway.new(options)
  end
end

module BraintreeData
  attr_reader :data
  def initialize(gateway, data)
    @data = data
    super
  end
end

ActiveMerchant::Billing::StripeGateway.class_eval do
  def unstore(customer_id, card_id = nil, options = {})
    customer = CGI.escape(customer_id)
    if card_id.blank?
      commit(:delete, "customers/#{customer}", nil, options)
    else
      commit(:delete, "customers/#{customer}/cards/#{CGI.escape(card_id)}", nil, options)
    end
  end
end

ActiveMerchant::Billing::OgoneGateway.class_eval do
  self.ssl_version = nil
end

class Braintree::ErrorResult
  prepend BraintreeData
end
