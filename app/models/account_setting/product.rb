# frozen_string_literal: true

class AccountSetting::Product < AccountSetting::StringSetting
  self.default_value = 'connect'

  validates :value, inclusion: { in: %w[connect enterprise] }
end
