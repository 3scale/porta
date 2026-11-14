# frozen_string_literal: true

class AccountSetting::MonthlyChargingEnabled < AccountSetting::BooleanSetting
  attribute :value, default: true
end
