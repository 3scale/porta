# frozen_string_literal: true

class AccountSetting::PermissionsPolicyHeaderDeveloper < AccountSetting::HttpHeaders
  # Default permissive policy for developer portal (empty = no restrictions)
  # Customers can customize this based on their needs
  self.default_value = ""
end
