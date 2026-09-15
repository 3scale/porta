# frozen_string_literal: true

class AccountSetting::ChangeServicePlanPermission < AccountSetting::StringSetting
  self.default_value = 'request'
  self.non_null = true

  validates :value, inclusion: { in: %w[request none credit_card request_credit_card direct] }
end
