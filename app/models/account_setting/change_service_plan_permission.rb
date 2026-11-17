# frozen_string_literal: true

class AccountSetting::ChangeServicePlanPermission < AccountSetting::StringSetting
  attribute :value, default: 'request'

  validates :value, inclusion: { in: %w[request none credit_card request_credit_card direct] }
end
