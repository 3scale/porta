module DashboardTimeRange
  def time_window
    30.days
  end

  def current_range
    today = Time.zone.now.to_date
    (today - time_window)..today
  end

  def previous_range
    (time_window + time_window).ago.to_date...current_range.min
  end
end
