# frozen_string_literal: true

class AccountSetting::CcTermsPath < AccountSetting::StringSetting
  attribute :value, default: '/termsofservice'

  validates :value, presence: true
end
