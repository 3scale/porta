# frozen_string_literal: true

# TODO: will become a CreditCard model by itself soon
module Account::CreditCard # rubocop:disable Metrics/ModuleLength(RuboCop)
  extend ActiveSupport::Concern

  included do
    before_destroy :unstore_credit_card_on_destroy!, if: -> { provider_account&.should_not_be_deleted? }

    scope :expired_credit_card, ->(time) {
      expired_credit_card = joins(:payment_detail).where.has do
        (credit_card_expires_on == time) | (payment_detail.credit_card_expires_on == time)
      end

      System::Database.mysql? ? expired_credit_card.distinct : where(id: expired_credit_card.select(:id))
    }

    after_commit :notify_credit_card_change
  end

  def credit_card
    @credit_card ||= begin
       admin = admins.first

       ActiveMerchant::Billing::CreditCard.new(:first_name => admin.try!(:first_name),
                                               :last_name => admin.try!(:last_name))
                     end
  end


  def credit_card_authorize_net_profile_stored?
    if provider_account && provider_account.payment_gateway_type == :authorize_net
      credit_card_auth_code.present?
    else
      credit_card_stored?
    end
  end

  def credit_card_stored?
    public_send(credit_card_stored_attribute).present?
  end

  def credit_card_stored_attribute
    case provider_account.try(:payment_gateway_type)
    when :authorize_net
      :credit_card_authorize_net_payment_profile_token
    when :stripe
      :credit_card_partial_number
    else
      :credit_card_auth_code
    end
  end

  # FIXME : Authorize.net does not provide expiration dates
  def credit_card_expired?
    if credit_card_expires_on
      credit_card_expires_on_with_default.end_of_month < Time.zone.today
    else
      false
    end
  end

  def credit_card_stored_and_valid?
    credit_card_stored? && !credit_card_expired?
  end

  def credit_card_display_number
    "XXXX-XXXX-XXXX-#{credit_card_partial_number}" if credit_card_partial_number.present?
  end

  def credit_card_expires_on_with_default
    credit_card_expires_on || Time.zone.today.change(:day => 1)
  end

  def credit_card_expires_on_year=(value)
    value = "20#{value}" if value.to_s.length == 2
    self.credit_card_expires_on = credit_card_expires_on_with_default.change(:year => value.to_i)
  end

  def credit_card_expires_on_month=(value)
    self.credit_card_expires_on = credit_card_expires_on_with_default.change(:month => value.to_i)
  end

  def wipe_buyers_cc_details!
    buyers.select { |b| b.credit_card_stored? }.each do |buyer|
      buyer.delete_cc_details
      buyer.save!
    end
  end

  def delete_cc_details
    self.credit_card_auth_code = nil
    self.credit_card_expires_on = nil
    self.credit_card_partial_number = nil
    self.credit_card_authorize_net_payment_profile_token = nil
  end

  def unstore_credit_card!
    begin
      response = provider_payment_gateway.try!(:threescale_unstore, credit_card_auth_code)
    rescue Account::Gateway::InvalidSettingsError => error
      Rails.logger.warn("Couldn't unstore credit card details from the payment gateway: #{error.message}")
    end

    unless payment_detail.destroyed?
      self.credit_card_auth_code = nil
      self.credit_card_expires_on = nil
      self.credit_card_partial_number = nil
    end

    response
  end

  private

  def unstore_credit_card_on_destroy!
    response = unstore_credit_card!
    notify_credit_card_unstore_failed(response.inspect) if response&.fail
  rescue => error
    notify_credit_card_unstore_failed(error.message)
  end

  def notify_credit_card_change
    credit_card_changes = saved_changes.slice(credit_card_stored_attribute,
                                              :credit_card_partial_number,
                                              :credit_card_expires_on)

    return unless credit_card_changes.present?

    old_auth_code, new_auth_code = credit_card_changes[credit_card_stored_attribute]
    old_partial_number, new_partial_number = credit_card_changes[:credit_card_partial_number]
    old_expires_on, _new_expires_on = credit_card_changes[:credit_card_expires_on]

    ThreeScale::Analytics
      .track_account(self,
                     'Credit Card Changed',
                     valid_previously: (old_auth_code && old_partial_number).present?,
                     valid_now: (new_auth_code && new_partial_number).present?,
                     expires_on: credit_card_expires_on,
                     expired_on: old_expires_on
      )
    ThreeScale::Analytics.group(self)
  end

  # voids the transaction with the +authorization+ code
  def void_transaction!(authorization)
    response = provider_payment_gateway.void(authorization)
    log_gateway_response(response, "void [transaction: #{authorization}]")
    response.success?
  end

  def notify_credit_card_unstore_failed(error)
    event = Accounts::CreditCardUnstoreFailedEvent.create(self, error)
    Rails.application.config.event_store.publish_event(event)
  end
end
