# frozen_string_literal: true

class PaymentTransaction < ApplicationRecord
  include Symbolize
  belongs_to :account
  belongs_to :invoice, inverse_of: :payment_transactions

  symbolize :action
  serialize :params
  has_money :amount

  validates :amount, presence: true
  validates :currency, length: {maximum: 4}
  validates :message, :reference, :action, length: {maximum: 255}

  attr_protected :account_id, :invoice_id, :success, :test, :tenant_id

  scope :failed, -> { where(:success => false) }
  scope :succeeded, -> { where(:success => true) }
  scope :oldest_first, -> { order(:created_at) }

  def process!(credit_card_auth_code, gateway, options)
    unless ThreeScale::Settings.get('payments.enabled')
      logger.info "Skipping payment transaction #process! - not in production"
      return
    end

    options[:currency] = currency

    logger.info("Processing PaymentTransaction with code #{credit_card_auth_code}, gateway #{gateway} & options #{options}")

    begin
      logger.info("Purchasing with #{gateway.class}")

      charging_service = Finance::ChargingService.new(gateway, buyer_reference: credit_card_auth_code, amount: amount, options: options.merge(invoice: invoice))
      response = charging_service.call

      self.success = response.success?
      self.reference = response.authorization
      self.message = response.message
      self.params = response.params
      self.test = response.test
    rescue ActiveMerchant::ActiveMerchantError => exception
      logger.info("Processing of PaymentTransaction threw an exception: #{exception.message}")
      self.success = false
      self.message = exception.message
      self.test = gateway.test?
      raise exception
    ensure
      logger.info("Saving PaymentTransaction")
      self.save!
    end

    unless response && response.success?
      logger.info("PaymentTransaction processing not successful. Response: #{response.inspect}")
      raise Finance::Payment::CreditCardPurchaseFailed.new(response)
    end

    self
  end

  # TODO: writable currency should be feature of the has_money plugin.
  # XXX: has_money plugin is a ghetoo
  module AmountWithCurrency
    def amount=(value)
      if value.respond_to?(:currency)
        super(value.amount)
        self.currency = value.currency
      else
        super(value)
      end
    end
  end
  prepend AmountWithCurrency


  def self.to_xml(payment_transactions, options = {})
    builder = ThreeScale::XML::Builder.new

    builder.payment_transactions do |xml|
      payment_transactions.each{ |pt| pt.to_xml(:builder => xml) }
    end

    builder.to_xml
  end

  def to_xml(options = {})
    xml = options[:builder] || ThreeScale::XML::Builder.new

    xml.payment_transaction do |xml|
      unless new_record?
        xml.id_ id
        xml.created_at created_at.xmlschema
        xml.updated_at updated_at.xmlschema
      end

      xml.invoice_id invoice_id
      xml.account_id account_id
      xml.reference reference
      xml.success success
      xml.amount amount
      xml.currency currency
      xml.action action
      xml.message message
      if params
        params.to_xml(root: 'gateway_response', builder: xml, skip_instruct: true, dasherize: false)
      else
        xml.gateway_response nil
      end
      xml.test test
    end

    xml.to_xml
  end
end
