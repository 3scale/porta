# frozen_string_literal: true

class PaymentGateway
  def initialize(type, options = {})
    @type = type
    @deprecated = options.delete(:deprecated).presence
    @fields = options
  end

  attr_reader :type, :deprecated, :fields

  # So far hardcoded list of gateways, later maybe this will be loaded from a config file or db.
  GATEWAYS = [
    PaymentGateway.new(:authorize_net, deprecated: true, login: 'LoginID', password: 'Transaction Key'),
    PaymentGateway.new(:braintree_blue, public_key: 'Public Key', merchant_id: 'Merchant ID', private_key: 'Private Key'),
    PaymentGateway.new(:ogone, deprecated: true, login: 'PSPID', password: 'Password', user: 'User Id', signature: "SHA-IN Pass phrase", signature_out: "SHA-OUT Pass phrase"),
    PaymentGateway.new(:stripe, login: "Secret Key", publishable_key: "Publishable Key"),
    PaymentGateway.new(:adyen12, login: 'Login', password: 'Secret Password', public_key: "Client Encryption Public Key", merchantAccount: 'Merchant ID', encryption_js_url: "Library location")
  ].freeze

  def self.bogus_enabled?
    Rails.env.development? or Rails.env.test?
  end

  def self.all
    gateways = GATEWAYS.dup

    if bogus_enabled?
      gateways << self.new(:bogus)
    end

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
  def self.implementation(type)
    ActiveMerchant::Billing::Base.gateway(type)
  end

  def implementation
    self.class.implementation(type)
  end

  delegate :display_name, :homepage_url, :to => :implementation

  def deprecated?
    !!deprecated
  end
end
