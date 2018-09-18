# frozen_string_literal: true

module Account::PaymentDetails
  extend ActiveSupport::Concern

  included do
    has_one :payment_detail, -> { order id: :desc }, autosave: true

    CREDIT_CARD_ATTRIBUTES = [
      :credit_card_auth_code,
      :credit_card_partial_number,
      :credit_card_expires_on,
      :credit_card_authorize_net_payment_profile_token
    ].freeze

    delegate(
      *CREDIT_CARD_ATTRIBUTES,
      *CREDIT_CARD_ATTRIBUTES.map { |attr| "#{attr}=" },
      *CREDIT_CARD_ATTRIBUTES.map { |attr| "#{attr}_was" },
      to: :payment_detail
    )

    define_callbacks :create_or_build_payment_detail, only: [:before, :after]

    set_callback :create_or_build_payment_detail, :after, :clear_cc_attributes
  end

  def payment_detail
    super || create_or_build_payment_detail
  end

  private

  def create_or_build_payment_detail
    run_callbacks :create_or_build_payment_detail do
      payment_detail_attributes = attributes.symbolize_keys.slice(*CREDIT_CARD_ATTRIBUTES)
      read_only_transaction = ActiveRecord::Base.connection.read_only_transaction?
      any_payment_attributes = payment_detail_attributes.any? { |_, value| value.present? }

      if persisted? && any_payment_attributes && !read_only_transaction
        create_payment_detail(payment_detail_attributes, &:do_not_notify)
      else
        build_payment_detail
      end
    end
  end

  def clear_cc_attributes
    self[:credit_card_auth_code] = nil
    self[:credit_card_partial_number] = nil
    self[:credit_card_expires_on] = nil
    self[:credit_card_authorize_net_payment_profile_token] = nil
  end
end
