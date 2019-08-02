module DeveloperPortal
  class ApplicationController < ::FrontendController

    include ::ThreeScale::ErrorReportingIgnoreEnduser
    error_reporting_ignore_enduser

    before_action :disable_for_suspended_provider_account

    protected

    def disable_for_suspended_provider_account
      if site_account && site_account.suspended?
        handle_buyer_side(:not_found)
      end
    end
  end
end
