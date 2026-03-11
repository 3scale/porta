# frozen_string_literal: true

class AccountSetting < ApplicationRecord
  self.store_full_sti_class = false

  # TODO: remove attr_accessible once protected_attributes_continued gem is removed
  attr_accessible :type, :value, :account, :tenant_id

  belongs_to :account, inverse_of: :account_settings

  audited associated_with: :account

  validates :value, presence: true

  delegate :provider_id_for_audits, to: :account, allow_nil: true

  def typed_assign(raw_value)
    self.value = self.class.serialize(raw_value)
  end
end
