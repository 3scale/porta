# frozen_string_literal: true

class Policy < ApplicationRecord
  belongs_to :account

  validates :version, uniqueness: { scope: %i[account_id name] }
end
