# frozen_string_literal: true

class AccountSetting::PermissionsPolicyHeaderAdmin < AccountSetting::HttpHeader
  def self.display_name = "Permissions-Policy Header"

  # Default restrictive policy for admin portal
  # Format: "directive1=(value1 value2), directive2=(value3)"
  self.default_value = "camera=(), microphone=(), geolocation=(), payment=(), usb=(), fullscreen=(self)"
end
