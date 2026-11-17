# frozen_string_literal: true

class AccountSetting::CspHeaderDeveloper < AccountSetting::HttpHeader
  def self.display_name = "Content-Security-Policy Header"

  # Default: empty string = no CSP header sent for developer portal
  attribute :value, default: ""
end
