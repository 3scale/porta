# frozen_string_literal: true

module TimeZoneHacks
  def current_month_range
    (now.beginning_of_month..now.end_of_month).to_time_range
  end

  def last_month_range
    ((now - 1.month)..now).to_time_range
  end

  def current_week_range
    (now.beginning_of_week..now.end_of_week).to_time_range
  end

  def last_week_range
    ((now - 1.week)..now).to_time_range
  end
end

ActiveSupport::TimeZone.send(:include, TimeZoneHacks)
