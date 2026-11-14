# frozen_string_literal: true

class AccountSetting::SSOKey < AccountSetting::StringSetting
  # Re-declaring audited replaces the parent's options, so associated_with is repeated here
  audited associated_with: :account, redacted: :value, redaction_value: '[FILTERED]'
end
