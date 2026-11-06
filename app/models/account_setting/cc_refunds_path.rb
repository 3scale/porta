# frozen_string_literal: true

class AccountSetting::CcRefundsPath < AccountSetting::StringSetting
  self.default_value = '/refundpolicy'

  validates :value, presence: true
end
