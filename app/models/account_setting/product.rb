# frozen_string_literal: true

class AccountSetting::Product < AccountSetting::StringSetting
  self.default_value = 'connect'
  self.non_null = true

  validates :value, inclusion: { in: %w[connect enterprise] }
end
