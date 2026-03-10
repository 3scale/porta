# frozen_string_literal: true

class AccountSetting::ChangeServicePlanPermission < AccountSetting::StringSetting
  validates :value, inclusion: { in: %w[request none credit_card request_credit_card direct] }
end
