# frozen_string_literal: true

class AccountSetting::SwitchSetting < AccountSetting
  VALID_VALUES = %w[denied hidden visible].freeze

  validates :value, inclusion: { in: VALID_VALUES }

  def self.cast(value)
    value&.to_s
  end

  def self.serialize(value)
    value.to_s
  end

  def typed_value
    value
  end
end
