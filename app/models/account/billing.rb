# TODO: place to the right folder
# TODO: extract to separate model / library / strategy
module Account::Billing
  extend ActiveSupport::Concern

  included do
    has_many :invoices, :foreign_key => 'buyer_account_id'
    after_save :update_invoices_vat_rates
    before_destroy :check_unresolved_invoices
  end

  # MODEL: Buyer
  def is_billed?
    provider_account && provider_account.is_billing_buyers?
  end

  def billable_contracts
    if provider_account.provider_can_use?(:billable_contracts)
      contracts.where.not(state: 'pending')
    else
      contracts
    end
  end

  def billable_contracts_with_trial_period_expired(now)
    if provider_account.provider_can_use?(:billable_contracts)
      billable_contracts.with_trial_period_expired_or_accepted(now)
    else
      billable_contracts.with_trial_period_expired(now)
    end
  end

  protected

  def update_invoices_vat_rates
    if saved_change_to_attribute?(:vat_rate) || will_save_change_to_attribute?(:vat_rate)
      self.invoices.not_frozen.reorder('').update_all(:vat_rate => self.vat_rate)
    end
  end

  # Will prevent the buyer from destroying if there are unresolved
  # invoices present.
  #
  def check_unresolved_invoices
    return true if !invoices.unresolved.exists? || should_be_deleted?
    errors.add(:invoices, :unresolved_invoices)
    throw :abort
  end

  def save_in_payment!
    @in_payment = true
    save!
  ensure
    @in_payment = false
  end

  public

  # This returns true only if account is in the middle of executing a payment (the pay! method,
  # account can be either the payer or the payee).
  #
  # This is used by observers, to differentiate between saving an account and just calling the
  # pay! method.
  def in_payment?
    @in_payment
  end

  # MODEL: Buyer
  # Charge this account the given amount via payment gateway.
  #
  # REFACTOR: move to billing strategy!
  #
  # options has :invoice
  def charge!(amount, options = {})
    unless credit_card_stored?
      logger.info("Buyer #{self.id} was not charged: credit card missing")
      raise Finance::Payment::CreditCardMissing
    end

    gateway_options = options.delete(:gateway_options) || {}

    transaction = payment_transactions.build(options.reverse_merge(:action => :purchase,
                                                                   :amount => amount))

    # add order_id
    if options[:invoice].is_a?(Invoice) && gateway_options.include?(:order_id)== false
      gateway_options[:order_id]= options[:invoice].id
    end

    gateway_options.reverse_merge!(payment_method_id: payment_detail.payment_method_id) if provider_payment_gateway.is_a?(ActiveMerchant::Billing::StripeGateway)

    logger.info("Processing transaction for buyer #{self.id} with code #{credit_card_auth_code}, gateway #{provider_payment_gateway} & options #{gateway_options}")

    transaction.process!(credit_card_auth_code, provider_payment_gateway, gateway_options)
  end


  # MODEL: Buyer
  # TODO: Remove?
  #
  def current_invoice
    invoices.opened.first
  end
end
