# frozen_string_literal: true

class AccountSetting::CspReportOnlyHeaderDeveloper < AccountSetting::HttpHeader
  def self.display_name = "Content-Security-Policy-Report-Only Header"

  attribute :value, default: ""
end
