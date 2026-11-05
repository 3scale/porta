# frozen_string_literal: true

class AccountSetting::AuthenticationStrategy < AccountSetting::StringSetting
  self.default_value = 'oauth2'
end
