# frozen_string_literal: true

class AccountSetting::CspHeaderAdmin < AccountSetting::HttpHeader
  def self.display_name = "Content-Security-Policy Header"

  self.default_value = ""
end
