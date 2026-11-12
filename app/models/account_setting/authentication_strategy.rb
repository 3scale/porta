# frozen_string_literal: true

class AccountSetting::AuthenticationStrategy < AccountSetting::StringSetting
  attribute :value, default: 'oauth2'

  validates :value, inclusion: { in: %w[internal oauth2 cas] }
end
