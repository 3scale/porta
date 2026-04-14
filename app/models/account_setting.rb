# frozen_string_literal: true

class AccountSetting < ApplicationRecord
  self.store_full_sti_class = false

  # TODO: remove attr_accessible once protected_attributes_continued gem is removed
  attr_accessible :type, :value, :account, :tenant_id

  belongs_to :account, inverse_of: :account_settings

  audited associated_with: :account

  validates :value, exclusion: { in: [nil], message: "cannot be nil" }

  delegate :provider_id_for_audits, to: :account, allow_nil: true

  class_attribute :default_value, instance_writer: false, default: nil

  # Derives setting name from class: AccountSetting::BgColour -> 'bg_colour'
  def self.setting_name
    sti_name.underscore
  end

  def self.display_name
    setting_name.titleize
  end

  # Instance methods that delegate to class methods
  delegate :setting_name, :default_value, :display_name, to: :class

  # Look up a setting class by its snake_case name
  # Dynamically constantizes the setting name under AccountSetting namespace
  # Example: :bg_colour -> AccountSetting::BgColour
  def self.class_for_setting(setting_name)
    class_name = setting_name.to_s.camelize
    "AccountSetting::#{class_name}".constantize
  rescue NameError
    nil
  end

end
