# frozen_string_literal: true

class AccountSetting::StringSetting < AccountSetting
  validates :value, length: { maximum: 255 }

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
