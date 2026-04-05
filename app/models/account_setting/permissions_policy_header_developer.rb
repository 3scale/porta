# frozen_string_literal: true

class AccountSetting::PermissionsPolicyHeaderDeveloper < AccountSetting::HttpHeaders
  # Default permissive policy for developer portal (empty = no header sent)
  self.default_value = ""
end
