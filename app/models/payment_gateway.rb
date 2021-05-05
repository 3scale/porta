# frozen_string_literal: true

class PaymentGateway
  def initialize(type, options = {})
    @type = type
    @deprecated = options.delete(:deprecated).presence
    @boolean_field_keys = options.delete(:boolean) || []
    @fields = options
  end

  def non_boolean_fields
    fields.except(*boolean_field_keys)
  end

  attr_reader :type, :deprecated, :fields, :boolean_field_keys

  # So far hardcoded list of gateways, later maybe this will be loaded from a config file or db.
  GATEWAYS = [
    PaymentGateway.new(:authorize_net, deprecated: true, login: 'LoginID', password: 'Transaction Key'),
    PaymentGateway.new(:braintree_blue, public_key: 'Public Key', merchant_id: 'Merchant ID', private_key: 'Private Key', three_ds_enabled: '3D Secure enabled', boolean: %i[three_ds_enabled]),
    PaymentGateway.new(:ogone, deprecated: true, login: 'PSPID', password: 'Password', user: 'User Id', signature: "SHA-IN Pass phrase", signature_out: "SHA-OUT Pass phrase"),
    PaymentGateway.new(:stripe, login: 'Secret Key', publishable_key: 'Publishable Key', endpoint_secret: 'Webhook Signing Secret')
  ].freeze

  def self.bogus_enabled?
    Rails.env.development? or Rails.env.test?
  end

  def self.all
    gateways = GATEWAYS.dup

    gateways << new(:bogus) if bogus_enabled?

    gateways
  end

  def self.active_for(account)
    all.reject { |gateway| gateway.deprecated && gateway.type != account.payment_gateway_type }
  end

  def self.types
    all.map(&:type)
  end

  def self.find(type)
    all.find { |gateway| gateway.type.to_s == type.to_s }
  end

  # Return ActiveMerchant's implementation (subclass of ActiveMerchant::Billing::Gateway)
  # of gateway of given type.
  #
  # Example:
  #
  # PaymentGateway.implementation(:authorize_net) # ActiveMerchant::Billing::AuthorizeNetGateway
  #
  # Note:
  #
  # Since ActiveMerchant 1.9, Braintree can return 2 different kinds of implementation:
  #     BraintreeOrangeGateway if :login is given or BraintreeeBlueGateway otherwise
  #
  #
  def self.implementation(type, **options)
    specific_type = options[:sca] && type == :stripe ? :stripe_payment_intents : type
    ActiveMerchant::Billing::Base.gateway(specific_type)
  end

  def implementation
    self.class.implementation(type)
  end

  delegate :display_name, :homepage_url, :to => :implementation

  def deprecated?
    !!deprecated
  end
end
