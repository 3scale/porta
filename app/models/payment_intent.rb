# frozen_string_literal: true

class PaymentIntent < ApplicationRecord
  SUCCEEDED_STATES = [Finance::StripeChargeService::PAYMENT_INTENT_SUCCEEDED].freeze

  belongs_to :invoice, inverse_of: :payment_intents

  validates :invoice, :reference, :state, presence: true
  validates :reference, :state, length: { maximum: 255 }
  validates :reference, uniqueness: true

  scope :latest, ->(count = 1) { reorder(created_at: :desc, id: :desc).limit(count) }
  scope :pending, ->() { where.not(state: SUCCEEDED_STATES) }

  scope :by_invoice, ->(invoice) { where(invoice: invoice) }

  def succeeded?
    SUCCEEDED_STATES.include?(state)
  end
end
