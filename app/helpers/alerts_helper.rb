# frozen_string_literal: true

module AlertsHelper
  def format_utilization value
    # &ge; == ≥
    "&ge;&nbsp;#{h value}&nbsp;%".html_safe
  end

  def colorize_utilization value
    content_tag :span, format_utilization(value), :class => "above-#{utilization_range(value)}"
  end

  def utilization_range value
    Alert::ALERT_LEVELS.inject(nil) do |last, range|
      return last if value.to_f < range
      range
    end
  end

  def row_for_alert_levels(label, key, hash = nil, levels = nil)
    hash ||= @service.notification_settings
    levels ||= alert_limits

    content_tag :tr, id: key, role: 'row' do
      (hidden_field_tag("service[notification_settings][#{key}][]", "") +
        content_tag(:td, label, role: 'cell')) << levels.map do |level|
          checked = hash.try!(:[], key.to_sym)&.include?(level)
          content_tag(:td, check_box_tag("service[notification_settings][#{key}][]", level, checked, title: "#{label} at #{level}% usage"), role: 'cell')
        end.join.html_safe # rubocop:disable Rails/OutputSafety
    end
  end

  def alert_limits
    @alert_limits ||= Alert::ALERT_LEVELS
  end

end
