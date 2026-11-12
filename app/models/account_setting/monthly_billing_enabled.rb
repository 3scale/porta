# frozen_string_literal: true

class AccountSetting::MonthlyBillingEnabled < AccountSetting::BooleanSetting
  attribute :value, default: true
end
