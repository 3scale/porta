# frozen_string_literal: true

class AccountSetting::CMSToken < AccountSetting::StringSetting
  include Concerns::SensitiveAudit
end
