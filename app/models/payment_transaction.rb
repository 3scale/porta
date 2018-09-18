class ::ActiveMerchant::Billing::AuthorizeNetGateway
  def cim_gateway
    @cim_gateway ||=  ::ActiveMerchant::Billing::AuthorizeNetCimGateway.new(options)
  end
end

class PaymentTransaction < ApplicationRecord
  belongs_to :account
  belongs_to :invoice, inverse_of: :payment_transactions

  symbolize :action
  serialize :params
  has_money :amount

  validates :amount, presence: true

  attr_protected :account_id, :invoice_id, :success, :test, :tenant_id

  scope :failed, -> { where(:success => false) }
  scope :succeeded, -> { where(:success => true) }
  scope :oldest_first, -> { order(:created_at) }

  def process!(credit_card_auth_code, gateway, gateway_options)
    if System::Application.config.three_scale.payments.enabled
      gateway_options[:currency] = currency

      logger.info("Processing PaymentTransaction with code #{credit_card_auth_code}, gateway #{gateway} & options #{gateway_options}")

      begin
        response = case gateway
                   when ActiveMerchant::Billing::AuthorizeNetGateway
          logger.info("Purchasing with authorize.net")
          purchase_with_authorize_net(credit_card_auth_code, gateway)
                   when ActiveMerchant::Billing::StripeGateway
          logger.info("Purchasing with stripe")
          purchase_with_stripe(credit_card_auth_code, gateway, gateway_options)
                   when ActiveMerchant::Billing::Adyen12Gateway
          logger.info("Purchasing with adyen v12")
          purchase_with_adyen12(credit_card_auth_code, gateway, gateway_options)
                   else
          logger.info("Purchasing with something other than authorize.net or stripe or adyen")
          gateway.purchase(amount.cents, credit_card_auth_code, gateway_options)
        end

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
    else
      logger.info "Skipping payment transaction #process! - not in production"
      return
    end
  end

  # TODO: writable currency should be feature of the has_money plugin.
  # XXX: has_money plugin is a ghetoo
  def amount_with_currency=(value)
    if value.respond_to?(:currency)
      self.amount_without_currency = value.amount
      self.currency = value.currency
    else
      self.amount_without_currency = value
    end
  end

  alias_method_chain :amount=, :currency

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

  private

  def purchase_with_authorize_net(credit_card_auth_code, gateway)
    profile_response = get_profile_response(credit_card_auth_code, gateway)
    if profile_response.success?
      payment_profiles = profile_response.params['profile']['payment_profiles']

      # BEWARE: payment_profiles could be a Hash or an Array
      payment_profile = payment_profiles.is_a?(Array) ? payment_profiles[-1] : payment_profiles
      payment_profile_id = payment_profile['customer_payment_profile_id']

      gateway.cim_gateway
        .create_customer_profile_transaction(:transaction => {
        :customer_profile_id => credit_card_auth_code,
        :customer_payment_profile_id => payment_profile_id,
        :type => :auth_capture,
        # BEWARE - THIS MUST NOT BE CENTS - Charging mess up from March 5,  2013
        :amount => amount.to_f })
    # gateway.cim_gateway.commit('AUTH_CAPTURE', money, post)
    else
      profile_response
    end
  end

  def get_profile_response(credit_card_auth_code, gateway)
    gateway.cim_gateway.get_customer_profile(:customer_profile_id => credit_card_auth_code)
  end

  def purchase_with_stripe(credit_card_auth_code, gateway, gateway_options)
    options = gateway_options.merge(customer: credit_card_auth_code)
    gateway.purchase(amount.cents, nil, options)
  end

  # Adyen uses another way to do recurring payments
  # They do not use the authorize/capture/purchase convention.
  # Recurring and basic payments are done on different endpoints than authorize/capture/purchase
  # * It needs to create a contract for recurring payment first
  # * After this contract is created then submitting a charge can be done
  def purchase_with_adyen12(credit_card_auth_code, gateway, gateway_options)
    options = {
      # Actually +credit_card_auth_code+ is the shopperReference
      # shopperReference: PaymentGateways::BuyerReferences.buyer_reference(account, account.provider_account),
      shopperReference: credit_card_auth_code,
      reference: PaymentGateways::BuyerReferences.charge_reference(account, invoice),
      recurring: 'RECURRING',
      shopperInteraction: 'ContAuth',
      selectedRecurringDetailReference: account.payment_detail.payment_service_reference.presence || 'LATEST',
      currency: gateway_options.fetch(:currency)
    }
    gateway.submit_recurring(amount.cents, options)
  end

end
