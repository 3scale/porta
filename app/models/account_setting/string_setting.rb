# frozen_string_literal: true

class AccountSetting::StringSetting < AccountSetting
  validates :value, length: { maximum: 255 }
end
