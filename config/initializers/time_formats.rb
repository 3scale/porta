Time::DATE_FORMATS[:full] = '%d. %b %Y %H:%M:%S'
Time::DATE_FORMATS[:db_month] = '%Y-%m'
Date::DATE_FORMATS[:db_month] = '%Y-%m'

# This is like the :number, but with trailing zeroes removed.
Time::DATE_FORMATS[:compact] = lambda { |time| time.to_s(:number).sub(/0{0,6}$/, '') }
Date::DATE_FORMATS[:compact] = Date::DATE_FORMATS[:number]
