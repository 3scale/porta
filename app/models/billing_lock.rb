# frozen_string_literal: true

class BillingLock < ApplicationRecord
  self.primary_key = :account_id

  belongs_to :account

  validates :account_id, presence: true, uniqueness: true
end
