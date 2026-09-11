# frozen_string_literal: true

class AccountSetting::AuthenticationStrategy < AccountSetting::StringSetting
  self.default_value = 'oauth2'
  self.non_null = true
end
