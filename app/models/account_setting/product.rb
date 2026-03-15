# frozen_string_literal: true

class AccountSetting::Product < AccountSetting::StringSetting
  validates :value, inclusion: { in: %w[connect enterprise] }
end
