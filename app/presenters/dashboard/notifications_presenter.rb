class Dashboard::NotificationsPresenter < Dashboard::MessagesPresenter
  IGNORED_NOTIFICATIONS = %w(csv_data_export daily_report weekly_report).freeze

  def initialize(notifications)
    super notifications.where.not(system_name: IGNORED_NOTIFICATIONS, title: nil).order(created_at: :desc)
  end

  def link_tag(notification)
    h.content_tag(:span, notification.title, class: notification_class(notification))
  end

  def notification_class(_message)
    'DashboardStream-notification'
  end
end
