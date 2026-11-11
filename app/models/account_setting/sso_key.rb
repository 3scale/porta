# frozen_string_literal: true

class AccountSetting::SSOKey < AccountSetting::StringSetting
  include Concerns::SensitiveAudit
end
