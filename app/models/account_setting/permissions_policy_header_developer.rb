# frozen_string_literal: true

class AccountSetting::PermissionsPolicyHeaderDeveloper < AccountSetting::HttpHeader
  def self.display_name = "Permissions-Policy Header"

  # Default permissive policy for developer portal (empty = no header sent)
  self.default_value = ""
end
