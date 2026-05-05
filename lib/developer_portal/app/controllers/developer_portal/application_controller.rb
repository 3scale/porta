# frozen_string_literal: true

module DeveloperPortal
  class ApplicationController < ::FrontendController

    before_action :disable_for_suspended_provider_account

    protected

    def disable_for_suspended_provider_account
      if site_account && site_account.suspended?
        handle_buyer_side(:not_found)
      end
    end

    private

    def set_security_headers
      {
        'Permissions-Policy'                  => 'permissions_policy_header_developer',
        'Content-Security-Policy'             => 'csp_header_developer',
        'Content-Security-Policy-Report-Only' => 'csp_report_only_header_developer'
      }.each do |header, setting_name|
        value = AccountSettings::SettingCache.fetch(account: site_account, setting_name: setting_name)
        response.headers[header] = value if value&.size&.nonzero?
      end
    end
  end
end
