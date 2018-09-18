module DeveloperPortal
  class DashboardsController < DeveloperPortal::BaseController

    before_action :provider_dashboard_if_provider

    activate_menu :dashboard
    liquify only: [ :show ], prefix: 'dashboards'


    def show
      # used in legacy liquid tag {% latest_messages %}
      @messages = current_account.received_messages.latest

      drop = Liquid::Drops::Account.new(current_account)
      # both deprecated
      assign_drops account: drop, buyer_account: drop


      unless site_account.multiple_applications_allowed?
        application = current_account.bought_cinstances.first
        drop = application ? Liquid::Drops::Application.new(application) : nil
        # both deprecated
        assign_drops application: drop, cinstance: drop
      end
    end

    protected

    def provider_dashboard_if_provider
      if !buyer_domain? || current_account.master?
        redirect_to provider_admin_dashboard_url
      end
    end

  end
end
