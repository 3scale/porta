# frozen_string_literal: true

class AccountSetting::TokenApi < AccountSetting::StringSetting
  attribute :value, default: 'default'
end
