# frozen_string_literal: true

class AccountSetting::UseraccountareaEnabled < AccountSetting::BooleanSetting
  attribute :value, default: true
end
