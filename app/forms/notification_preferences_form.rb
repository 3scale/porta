class NotificationPreferencesForm < Reform::Form
  include ThreeScale::Reform

  attr_reader :current_user, :user_ability

  delegate :update_attributes,    to: :model
  delegate :has_permission?,      to: :current_user
  delegate :account,              to: :current_user
  delegate :can?,                 to: :user_ability
  delegate :event_mapping,        to: NotificationMailer
  delegate :required_abilities,   to: NotificationMailer
  delegate :hidden_notifications, to: NotificationMailer
  delegate :hidden_onprem_multitenancy, to: NotificationMailer

  NotificationCategory = Struct.new(:title_key, :notifications)

  CATEGORIES = [:account, :billing, :application, :service, :service_plan, :alert, :report].freeze

  def initialize(current_user, preferences)
    @current_user = current_user
    @user_ability = Ability.new(current_user)

    super preferences
  end

  def categories
    @categories ||= begin
      visible_categories = Hash.new { |h, k| h[k] = [] }

      model.available_notifications.each do |notification|
        next if invisible?(notification) || !authorize_event_abilities(notification)

        event_class = event_mapping.fetch(notification.to_sym)
        visible_categories[event_class.category] << notification
      end

      notification_categories(visible_categories)
    end
  end

  private

  def notification_categories(visible_categories)
    ui_notification_categories = []

    enabled_categories.each do |category_name|
      ui_title_key  = category_ui_title_key(category_name)
      notifications = Array(visible_categories[category_name])
      category      = ui_notification_categories.find { |c| c.title_key == ui_title_key }

      if category.present?
        category.notifications += notifications
      else
        ui_notification_categories << NotificationCategory.new(ui_title_key, notifications)
      end
    end

    ui_notification_categories
  end

  # some categories have independent "enabled?" conditions
  # but in the UI should be merged with another category
  def category_ui_title_key(category)
    case category
    when :service_plan then :service
    else category
    end
  end

  def invisible?(notification)
    notification_name = notification.to_sym

    hidden_notifications.include?(notification_name) || hidden_onprem_multitenancy?(notification_name)
  end

  def hidden_onprem_multitenancy?(notification)
    hidden_onprem_multitenancy.include?(notification) && account.master_on_premises?
  end

  def authorize_event_abilities(notification)
    abilities = Array(required_abilities[notification.to_sym])

    abilities.all? { |ability| can?(*ability) }
  end

  def enabled_categories
    CATEGORIES.select { |category| enabled?(category) }
  end

  def enabled?(category)
    case category
    when :billing
      has_permission?(:finance) && provider_is_billing? && !provider.master_on_premises?
    when :account
      has_permission?(:partners)
    when :application
      has_permission?(:partners) && at_least_one_service?
    when :alert
      at_least_one_service? && has_permission?(:monitoring)
    when :service_plan
      current_user.provider_account.settings.service_plans_ui_visible? &&
        at_least_one_service? && has_permission?(:partners)
    when :report
      has_permission?(:partners) && current_user.admin? && Rails.application.config.three_scale.daily_weekly_reports_pref
    when :service
      at_least_one_service? && has_permission?(:partners)
    else
      false
    end
  end

  def provider_is_billing?
    provider.is_billing_buyers?
  end

  def provider
    @provider ||= account.provider? ? account : account.provider_account
  end

  def at_least_one_service?
    return @at_least_one_service if defined?(@at_least_one_service)

    @at_least_one_service = current_user_services.present?
  end

  def current_user_services
    @current_user ||= current_user.accessible_services
  end
end
