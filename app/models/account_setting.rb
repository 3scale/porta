# frozen_string_literal: true

class AccountSetting < ApplicationRecord
  belongs_to :account, inverse_of: :account_settings

  audited associated_with: :account

  validates :value, presence: true

  delegate :provider_id_for_audits, to: :account, allow_nil: true

  def assign_casted(raw_value)
    self.value = self.class.serialize(raw_value)
  end
end
