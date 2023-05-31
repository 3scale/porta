# frozen_string_literal: true

class Month < Range

  PERIOD_STRING_FORMAT = '%Y-%m'
  INVALID_DATE_ERROR = "First day must be date or respond to to_date"

  # Accepts either day of the month, or year and day as a
  # parameter:
  #
  # Month.new(Time.zone.local(2009,1,3))
  #
  # or easier
  #
  # Month.new(2009,1)
  #
  def initialize(*args)
    case args.length
    when 1
      first_day = first_day_from_date(args.first)
    when 2
      first_day = first_day_from_year_and_month(*args)
    else
      raise ArgumentError, 'Wrong number of arguments'
    end

    super(first_day.beginning_of_month, first_day.end_of_month)
  end

  delegate :mon, :strftime, to: :first

  # Returns month after that one.
  #
  def next
    Month.new(self.begin + 1.month)
  end

  def previous
    Month.new(self.begin - 1.month)
  end

  def same_month?(date)
    date.beginning_of_month == self.begin
  end

  def to_param
    self.begin.to_s(:db_month)
  end

  delegate :to_json, :to => :to_param

  def to_s(format = :long)
    begin_formatted = self.begin.to_s(format)
    if format == :db
      begin_formatted
    else
      "#{begin_formatted} - #{self.end.to_s(format)}"
    end
  end

  def self.current
    time_now = Time.zone.now
    time_now.beginning_of_month..time_now.end_of_month
  end

  def self.parse_month(month)
    return month if month.is_a?(Month)

    raise ArgumentError unless /^\d{4}-\d{2}$/.match?(month)

    month_params = month.split('-').first(2)
    Month.new(*month_params)
  rescue ArgumentError, NoMethodError, RangeError
    nil
  end

  def to_time_range
    # This looks too convoluted, but can't really use begin.to_time / end.to_time, because
    # that returns the time in the system local time zone, but Time.zone.local returns
    # it in Rails' local time zone (which can be different apparently).
    time_zone = Time.zone
    my_begin = self.begin
    my_end = self.end
    TimeRange.new(time_zone.local(my_begin.year, my_begin.month, my_begin.day),
                  time_zone.local(my_end.year,   my_end.month,   my_end.day).end_of_day)
  end

  def as_json(*)
    { begin: self.begin, end: self.end }
  end

  private

  def first_day_from_year_and_month(year, month)
    Time.zone.local(year,month,1).to_date
  end

  def first_day_from_date(date)
    date.to_date
  rescue ArgumentError
    raise ArgumentError, INVALID_DATE_ERROR
  end

end
