# frozen_string_literal: true

class AccountSetting::StringSetting < AccountSetting
  attribute :value, :string

  validates :value, length: { maximum: 255 }
end
