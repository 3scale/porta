# frozen_string_literal: true

class AccountSetting::PermissionsPolicyHeaderDeveloper < AccountSetting::HttpHeader
  def self.display_name = "Permissions-Policy Header"

  # Default permissive policy for developer portal (empty = no header sent)
  attribute :value, default: ""
end
