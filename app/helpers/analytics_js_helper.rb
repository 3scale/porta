module AnalyticsJsHelper
  def analytics
    enabled = segment.enabled && @_analytics_enabled

    capture { yield(enabled) } if block_given?
  end

  def segment
    System::Application.config.three_scale.segment
  end

  def session_signup_success_user_id
    signup = session[:signup_success]
    signup && signup[:user_id]
  end

  include ThreeScale::Analytics::SessionStoredAnalytics::Helper
end
