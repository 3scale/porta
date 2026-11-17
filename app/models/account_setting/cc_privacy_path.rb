# frozen_string_literal: true

class AccountSetting::CcPrivacyPath < AccountSetting::StringSetting
  attribute :value, default: '/privacypolicy'

  validates :value, presence: true
end
