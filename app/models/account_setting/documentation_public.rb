# frozen_string_literal: true

class AccountSetting::DocumentationPublic < AccountSetting::BooleanSetting
  attribute :value, default: true
end
