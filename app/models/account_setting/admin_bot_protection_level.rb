# frozen_string_literal: true

class AccountSetting::AdminBotProtectionLevel < AccountSetting::StringSetting
  attribute :value, default: 'none'

  validates :value, inclusion: { in: %w[none captcha] }
end
