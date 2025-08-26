# frozen_string_literal: true

class NotificationCategories

  AVAILABLE_CATEGORIES = %i[account billing application service service_plan alert report].freeze
  CATEGORIES_UI_ORDER = %i[account service application billing alert report].freeze

  def initialize(user)
    @user = user
  end

  def enabled_categories
    AVAILABLE_CATEGORIES.select { enabled?(_1) }
  end

  def enabled?(category)
    case category
    when :billing
      @user.has_permission?(:finance) && provider_is_billing? && !provider.master_on_premises?
    when :account
      @user.has_permission?(:partners)
    when :application
      @user.has_permission?(:partners) && at_least_one_service?
    when :alert
      at_least_one_service? && @user.has_permission?(:monitoring)
    when :service_plan
      @user.account.settings.service_plans_ui_visible? &&
        at_least_one_service? && @user.has_permission?(:partners)
    when :report
      @user.has_permission?(:partners) && @user.admin? && Rails.application.config.three_scale.daily_weekly_reports_pref
    when :service
      at_least_one_service? && @user.has_permission?(:partners)
    else
      false
    end
  end

  private

  def provider_is_billing?
    provider.is_billing_buyers?
  end

  def provider
    account = @user.account
    @provider ||= account.provider? ? account : account.provider_account
  end

  def at_least_one_service?
    return @at_least_one_service if defined?(@at_least_one_service)

    @at_least_one_service = current_user_services.present?
  end

  def current_user_services
    @current_user_services ||= @user.accessible_services
  end
end
