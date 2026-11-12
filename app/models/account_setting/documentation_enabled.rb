# frozen_string_literal: true

class AccountSetting::DocumentationEnabled < AccountSetting::BooleanSetting
  attribute :value, default: true
end
