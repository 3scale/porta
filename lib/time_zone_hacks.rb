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

# backported from rails 3
module TimeZoneSerialization
  def encode_with(coder)
    if coder.respond_to?(:represent_object)
      coder.represent_object(nil, utc)
    else
      coder.represent_scalar(nil, utc.strftime("%Y-%m-%d %H:%M:%S.%9NZ"))
    end
  end
end

ActiveSupport::TimeWithZone.send(:include, TimeZoneSerialization)
