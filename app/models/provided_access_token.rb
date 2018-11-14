# frozen_string_literal: true

class ProvidedAccessToken < ApplicationRecord
  belongs_to :user, required: true
  has_one :account, through: :user

  default_scope -> { order(expires_at: :desc)}
  scope :valid, -> { where.has { expires_at > Time.now.utc } }
  scope :expired, ->(time = Time.now.utc) { where.has { expires_at <= time } }
  scope :long_expired, -> { expired(1.day.ago.end_of_day) }
end
