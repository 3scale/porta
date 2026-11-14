# frozen_string_literal: true

class AccountSetting::SpamProtectionLevel < AccountSetting::StringSetting
  attribute :value, default: 'none'

  validates :value, inclusion: { in: %w[none captcha auto] }
end
