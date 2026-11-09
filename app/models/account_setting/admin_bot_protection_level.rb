# frozen_string_literal: true

class AccountSetting::AdminBotProtectionLevel < AccountSetting::StringSetting
  self.default_value = 'none'

  validates :value, inclusion: { in: %w[none captcha] }
end
