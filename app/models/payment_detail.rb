# frozen_string_literal: true

class PaymentDetail < ApplicationRecord
  ATTRIBUTES = [:buyer_reference, :payment_service_reference, :credit_card_partial_number, :credit_card_expires_on].freeze

  set_date_columns :credit_card_expires_on

  class_attribute :notify_changes
  self.notify_changes = true

  belongs_to :account

  audited :allow_mass_assignment => true

  attr_protected :account_id, :audit_ids

  validates :credit_card_partial_number, length: { :maximum => 4,
                                                   :allow_blank => true,
                                                   :message => "must be the final 4 digits only" }
  validates :credit_card_auth_code, :credit_card_authorize_net_payment_profile_token, length: {maximum: 255}

  alias_attribute :credit_card_auth_code, :buyer_reference
  alias_attribute :credit_card_authorize_net_payment_profile_token, :payment_service_reference

  after_commit :notify_credit_card_changes, if: :notify_changes?

  class CreditCardChangeNotifier
    attr_reader :account, :changes

    def initialize(account, changes)
      @account = account
      @changes = changes
    end

    def call
      credit_card_changes = changes.slice(*PaymentDetail::ATTRIBUTES)

      return if credit_card_changes.blank?

      ThreeScale::Analytics.track_account(account, 'Credit Card Changed', credit_card_changes_for_analytics(credit_card_changes))
      ThreeScale::Analytics.group(account)
    end

    protected

    def credit_card_changes_for_analytics(credit_card_changes)
      old_buyer_reference, new_buyer_reference = credit_card_changes[:buyer_reference]
      old_partial_number, new_partial_number = credit_card_changes[:credit_card_partial_number] || credit_card_changes[:payment_service_reference]
      old_expires_on, new_expires_on = credit_card_changes[:credit_card_expires_on]

      {
        valid_previously: (old_buyer_reference && old_partial_number).present?,
        valid_now: (new_buyer_reference && new_partial_number).present?,
        expires_on: new_expires_on,
        expired_on: old_expires_on
      }
    end
  end

  def changed_for_autosave?
    super && (persisted? || any_values?)
  end

  def any_values?
    ATTRIBUTES.any? { |attr| public_send(attr).present? }
  end

  def notify_changes?
    notify_changes
  end

  def do_not_notify
    self.notify_changes = false
  end

  private

  def notify_credit_card_changes
    CreditCardChangeNotifier.new(account, previous_changes).call
  end
end
