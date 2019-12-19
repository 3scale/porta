module TimeHacks
  def beginning_of_cycle(cycle)
    if cycle.is_a?(Symbol)
      beginning_of(cycle)
    else
      base = cycle_base(cycle)

      cycles_count = ((self - base) / cycle).floor
      base + cycles_count * cycle
    end
  end

  def end_of_cycle(cycle)
    if cycle.is_a?(Symbol)
      end_of(cycle)
    else
      base = cycle_base(cycle)

      cycles_count = ((self - base) / cycle).ceil
      (base + cycles_count * cycle - 1.second).end_of_minute
    end
  end

  # Wrapper for all the beginning_of_X methods (beginning_of_day, beginning_of_month, ...)
  def beginning_of(period)
    case period
    when :eternity                  then change(:year => 1970, :month => 1, :day => 1, :hour => 00, :min => 00, :sec => 00)
    when :day, :week, :month, :year, :hour, :minute then send("beginning_of_#{period}")
    else raise_invalid_period(period)
    end
  end

  # Wrapper for all the end_of_X methods (end_of_day, end_of_month, ...)
  def end_of(period)
    case period
    when :eternity                  then change(:year => 9999, :month => 12, :day => 31, :hour => 23, :min => 59, :sec => 59)
    when :day, :week, :month, :year, :hour, :minute then send("end_of_#{period}")
    else raise_invalid_period(period)
    end
  end

  private

  def raise_invalid_period(period)
    raise ArgumentError, "Argument must be one of :minute, :hour, :day, :week, :month, or :year, not #{period.inspect}"
  end

  def cycle_base(cycle)
    case cycle
    when 0..1.minute      then change(:sec => 0)
    when 1.minute..1.hour then change(:min => 0)
    when 1.hour..1.day    then change(:hour => 0)
    else raise ArgumentError, "Argument must be duration from 0 seconds to 1 day."
    end
  end
end

Time.send(:include, TimeHacks)
