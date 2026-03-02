# frozen_string_literal: true

class AccountSetting::SpamProtectionLevel < AccountSetting::StringSetting
  self.default_value = 'none'
  self.non_null = true
end
