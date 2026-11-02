# frozen_string_literal: true

class AccountSetting::CcPrivacyPath < AccountSetting::StringSetting
  self.default_value = '/privacypolicy'

  validates :value, presence: true
end
