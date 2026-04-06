# frozen_string_literal: true

module DeveloperPortal
  class ApplicationController < ::FrontendController

    before_action :disable_for_suspended_provider_account

    private

    def set_permissions_policy_header
      header_value = AccountSettings::CachedRetrievalService.call(
        account: site_account,
        setting_name: 'permissions_policy_header_developer'
      ).result

      # Set header only if value is present (even if only whitespaces)
      response.headers['Permissions-Policy'] = header_value if header_value&.size&.nonzero?
    end

    protected

    def disable_for_suspended_provider_account
      if site_account && site_account.suspended?
        handle_buyer_side(:not_found)
      end
    end
  end
end
