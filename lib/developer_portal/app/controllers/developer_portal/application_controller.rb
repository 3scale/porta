# frozen_string_literal: true

module DeveloperPortal
  class ApplicationController < ::FrontendController
    include CMS::Toolbar

    before_action :disable_for_suspended_provider_account

    protected

    def disable_for_suspended_provider_account
      if site_account && site_account.suspended?
        handle_buyer_side(:not_found)
      end
    end
  end
end
