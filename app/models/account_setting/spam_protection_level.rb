# frozen_string_literal: true

class AccountSetting::SpamProtectionLevel < AccountSetting::StringSetting
  self.default_value = 'none'
end
