# frozen_string_literal: true

class AccountSetting::CcRefundsPath < AccountSetting::StringSetting
  attribute :value, default: '/refundpolicy'

  validates :value, presence: true
end
