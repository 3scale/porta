# frozen_string_literal: true

class AccountSetting::StringSetting < AccountSetting
  attribute :value, :string, limit: 255

  validates :value, length: { maximum: 255 }
end
