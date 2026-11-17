# frozen_string_literal: true

class AccountSetting::SignupsEnabled < AccountSetting::BooleanSetting
  attribute :value, default: true
end
