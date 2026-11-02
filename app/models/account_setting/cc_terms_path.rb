# frozen_string_literal: true

class AccountSetting::CcTermsPath < AccountSetting::StringSetting
  self.default_value = '/termsofservice'

  validates :value, presence: true
end
