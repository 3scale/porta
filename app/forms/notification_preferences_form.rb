class NotificationPreferencesForm < Reform::Form
  include ThreeScale::Reform

  attr_reader :current_user, :user_ability

  delegate :update,               to: :model
  delegate :account,              to: :current_user
  delegate :can?,                 to: :user_ability
  delegate :event_mapping,        to: NotificationMailer
  delegate :required_abilities,   to: NotificationMailer
  delegate :hidden_notifications, to: NotificationMailer
  delegate :hidden_onprem_multitenancy, to: NotificationMailer

  FormCategory = Struct.new(:title_key, :notifications)

  def initialize(current_user, preferences)
    @current_user = current_user
    @user_ability = Ability.new(current_user)
    @enabled_categories = NotificationCategories.new(@current_user).enabled_categories

    super preferences
  end

  def categories
    @categories ||= begin
      form_categories = []

      model.available_notifications.each do |notification|
        next if invisible?(notification) || !authorize_event_abilities(notification)

        event_class = event_mapping.fetch(notification.to_sym)
        category_name = event_class.category

        next unless @enabled_categories.include?(category_name)

        ui_title_key  = category_ui_title_key(category_name)

        form_category = form_categories.find { _1.title_key == ui_title_key }

        if form_category.present?
          form_category.notifications << notification
        else
          form_categories << FormCategory.new(ui_title_key, [notification])
        end
      end

      form_categories.sort_by! { NotificationCategories::CATEGORIES_UI_ORDER.index(_1.title_key) }
    end
  end

  private

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
end
