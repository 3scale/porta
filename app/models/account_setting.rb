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

  class_attribute :default_value, instance_writer: false, default: nil
  class_attribute :non_null, instance_writer: false, default: false

  # Derives setting name from class: AccountSetting::BgColour -> :bg_colour
  def self.setting_name
    sti_name.underscore.to_sym
  end
end
