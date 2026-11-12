# frozen_string_literal: true

class AccountSetting::Product < AccountSetting::StringSetting
  attribute :value, default: 'connect'

  validates :value, inclusion: { in: %w[connect enterprise] }
end
