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
    if args.length == 2
      year, month = args
      # the weird .to_datetime.to_date is for 1.9 compatibility
      first_day = Time.zone.local(year,month,1).to_datetime.to_date
    elsif args.length == 1
      raise ArgumentError.new(INVALID_DATE_ERROR) unless quacks_like_date?(args.first)
      first_day = args.first.to_date
    else
      raise ArgumentError.new('Wrong number of arguments')
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

  def is_same_month?(date)
    date.beginning_of_month == self.begin
  end

  def to_param
    self.begin.to_s(:db_month)
  end

  delegate :to_json, :to => :to_param

  # TODO: DRY with the same method at TimeRange
  def to_s(format = nil)
    if format == :db
      self.begin.to_s
    else
      "#{self.begin.to_date.to_s(:long)} - #{self.end.to_date.to_s(:long)}"
    end
  end

  def self.current
    Time.zone.now.beginning_of_month..Time.zone.now.end_of_month
  end

  # TODO: replace implementation by strptime
  def self.parse_month(month)
    return unless month || month.present?

    date = if month.is_a?(String)
             # Timecop overrides Date.striptime with:
             # `Time.strptime(month, "%Y-%m").to_date`
             # and that fails with '1022-05' as month
             # try: `Time.strptime('1022-05', "%Y-%m").to_date`
             # Wed, 25 Apr 1022
             DateTime.strptime(month, "%Y-%m").to_date
           else
             month
           end

    Month.new(date.beginning_of_month)
  rescue ArgumentError
    # return nil
  end

  def to_time_range
    # This looks too convoluted, but can't really use begin.to_time / end.to_time, because
    # that returns the time in the system local time zone, but Time.zone.local returns
    # it in Rails' local time zone (which can be different apparently).
    TimeRange.new(Time.zone.local(self.begin.year, self.begin.month, self.begin.day),
                  Time.zone.local(self.end.year,   self.end.month,   self.end.day).end_of_day)
  end

  def as_json(options = {})
    { begin: self.begin, end: self.end }
  end

  private

  def quacks_like_date?(date)
    date.acts_like?(:date) || date.respond_to?(:to_date)
  end

end
