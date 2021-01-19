# frozen_string_literal: true

class PaymentIntent < ApplicationRecord
  belongs_to :invoice, inverse_of: :payment_intents

  validates :invoice, :payment_intent_id, :state, presence: true
  validates :payment_intent_id, :state, length: { maximum: 255 }

  scope :latest, -> (count = 1) { reorder(created_at: :desc, id: :desc).limit(count) }
  scope :latest_pending, -> (count = 1) { where.not(state: :succeeded).latest(count) }
end
