
module AppendExceptionPayload
  module ControllerRuntime
    extend ActiveSupport::Concern

    protected

    def append_info_to_payload(payload)
      super

      return unless User.current.try!(:account).try!(:provider?)

      payload[:user_session] = cookies.signed[:user_session] if cookies
      payload[:flash] = flash || {}
      payload[:google_experiments] = google_experiments if respond_to?(:google_experiments)
    end
  end
end

ActiveSupport.on_load :action_controller do
  include AppendExceptionPayload::ControllerRuntime
end

# Note: There are some events about GoLiveState in FrontendController

class TrackingNotifications < Struct.new(:name, :start, :finish, :id, :payload)

  def self.provider_request(*args)
    new(*args).provider_request
  end

  def initialize(*)
    super
    @analytics = ThreeScale::Analytics.user_tracking(current_user)
  end

  def current_user
    User.current
  end

  def params
    payload[:params]
  end

  def action
    payload[:action].to_s.inquiry
  end

  def controller
    payload[:controller]
  end

  def flash
    payload[:flash] || {}
  end

  def google_experiments
    payload[:google_experiments] || {}
  end

  def controller_action_method
    "#{controller}##{action}"
  end

  def provider?
    current_user.try!(:account).try!(:provider?)
  end

  def raise_exceptions?
    Rails.env.development? or Rails.env.test?
  end

  def daily(&block)
    @analytics.cached(1.day, &block)
  end

  def hourly(&block)
    @analytics.cached(1.hour, &block)
  end

  def provider_request
    return unless provider?

    hourly do |cached|
      cached.identify(cached.extended_traits.merge(google_experiments))
      cached.group
    end

    case controller_action_method

    when "Provider::SessionsController#create"
        @analytics.track('Login') if flash[:notice]

    when "Provider::Admin::Account::InvitationsController#create"
        @analytics.track('Sent invitation') if flash[:notice]

    when /Provider::Admin::CMS::(.)*#(create|update)/
        if flash[:notice]
          @analytics.track('Edited a page')
          if params["publish"].present?
            @analytics.track('Published a page')
          end
        end

    when /Provider::Admin::CMS::(.)*#sidebar/
        @analytics.track('Visited CMS')

    when "Sites::DnsController#update"
        if flash[:notice] && params["account"]["site_access_code"].blank?
          @analytics.track('Developer portal opened')
        end

    when "Admin::ApiDocs::ServicesController#new"
        @analytics.track('Visited New AD Spec')

    when /Admin::ApiDocs::ServicesController#(create|update)/
        if flash[:notice]
          @analytics.track('Created AD Spec')            if action.create?
          if params["api_docs_service"]["published"]
            @analytics.track('Published AD Spec')
          end
        end
    when /Api::(.)*PlansController#create/
        if payload[:status] == 302 # redirect means success
          @analytics.track('Created plan', type: controller)
        end

    when /Provider::Admin::GoLiveStatesController#update/
        @analytics.track("Ready to launch")

    when "Buyers::AccountsController#index"
        daily do |cached|
          cached.track('Accessed Account Tab')
        end

    when "Buyers::AccountsController#update"
        @analytics.track('Account Updated') if action.update?

    when "Buyers::ApplicationsController#index"
        daily do |cached|
          cached.track('Accessed Application Tab')
        end

    when "Finance::Provider::DashboardsController#index"
        daily do |cached|
          cached.track('Accessed Finance Tab')
        end

    when 'Stats::DashboardsController#index', 'Stats::ApplicationsController#show'
        daily do |cached|
          cached.track('Accessed Monitoring Tab')
        end
    when "Api::ServicesController#index"
        daily do |cached|
          cached.track('Accessed API Tab')
        end

    when "Sites::UsageRulesController#edit"
        @analytics.track('Visited Settings')

    when "Sites::UsageRulesController#update"
        status = (params["settings"]["account_plans_ui_visible"] == "1") ? "visible" : "hidden"
        @analytics.track('Updated Settings', 'Account plans' => status)

        status = (params["settings"]["service_plans_ui_visible"] == "1") ? "visible" : "hidden"
        @analytics.track('Updated Settings', 'Service plans' => status)
    end

  rescue Exception => exception
    raise if raise_exceptions?

    System::ErrorReporting.report_error(exception,
                    error_message: 'Event tracking failed',
                    parameters: { request_params: params,
                                  controller_action: controller_action_method,
                                  payload: payload })
    Rails.logger.error "--> Event tracking error (but rescued)"
    Rails.logger.error exception
    Rails.logger.error exception.backtrace.join("\n\t")
  end
end

ActiveSupport::Notifications.subscribe 'process_action.action_controller',
                                       &TrackingNotifications.method(:provider_request)
