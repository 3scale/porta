# frozen_string_literal: true

class ProvidedAccessToken < ApplicationRecord
  belongs_to :user, required: true
  belongs_to :account, required: true

  default_scope -> { order(expires_at: :desc)}
  scope :valid, -> { where.has { expires_at > Time.now.utc } }

  before_validation on: :create do
    self.account ||= user.account
  end
end
