class Dashboard::MessagesPresenter
  include ::Draper::ViewHelpers

  LIMIT = 16

  attr_reader :all_messages

  def initialize(all_messages)
    @all_messages = all_messages.limit(LIMIT)
  end

  def render
    h.capture do
      todays_messages, older_messages = all_messages.partition do |message|
        message.created_at.today?
      end

      h.concat render_messages(todays_messages, :today)

      if todays_messages.length != LIMIT
        h.concat render_messages(older_messages, :older)
      end
    end
  end

  private

  def render_messages(messages, title_key)
    h.concat title_tag(title_key)
    h.content_tag(:ol, class: 'DashboardStream-list'.freeze) do
      if messages.any?
        messages.each { |message| h.concat row_tag(message) }
      else
        h.concat empty_tag
      end
    end
  end

  def title_tag(title_key)
    h.content_tag(:h1, t(title_key), class: 'DashboardStream-title'.freeze)
  end

  def row_tag(message)
    h.content_tag(:li, link_tag(message), class: 'DashboardStream-listItem'.freeze)
  end

  def empty_tag
    h.content_tag(:li, no_messages_message,
                  class: 'DashboardStream-listItem DashboardStream-listItem--empty'.freeze)
  end

  def no_messages_message
    index = Rails.env.test? ? 1 : rand(1..6)
    t("no_messages_#{index}")
  end

  def link_tag(message)
    h.content_tag(:a, h.message_subject(message), class: message_class(message),
                                                  href: h.provider_admin_messages_inbox_path(message))
  end

  def message_class(message)
    "DashboardStream-link DashboardStream-link--#{message.state}"
  end

  def notification_class(_message)
    'DashboardStream-notification'
  end

  def t(key)
    I18n.t("provider.admin.dashboards.show.#{key}")
  end
end
