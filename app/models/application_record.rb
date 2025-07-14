# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include Annotating
  include BackgroundDeletion

  def self.user_attribute_names
    attribute_names
  end

  sifter(:regexp) do |column, matcher|
    case System::Database.adapter.to_sym
    when :mysql
      ["#{column} REGEXP ?", matcher]
    when :postgres
      ["#{column} ~* ?", matcher]
    when :oracle
      ["REGEXP_LIKE(#{column}, ?)", matcher]
    end
  end

  sifter(:month_number) do |column|
    case System::Database.adapter.to_sym
    when :mysql
      func(:month, column)
    when :postgres
      cast(func(:to_char, column, quoted('MM')).as('integer'))
    when :oracle
      func(:to_number, func(:to_char, column, quoted('MM')))
    end
  end

  sifter(:year) do |column|
    case System::Database.adapter.to_sym
    when :mysql
      func(:year, column)
    when :postgres
      cast(func(:to_char, column, quoted('YYYY')).as('integer'))
    when :oracle
      func(:to_number, func(:to_char, column, quoted('YYYY')))
    end
  end

  sifter :date do |column|
    name = System::Database.oracle? ? :trunc : :date

    func(name, column)
  end

  sifter :to_date do |value, format='%Y-%m-%d'|
    name = System::Database.mysql? ? :str_to_date : :to_date
    func(name, value, quoted(DatabaseUtilities.convert_to_oracle_date_format(format)))
  end

  sifter :in_timezone do |column, timezone_name = Time.zone.tzinfo.name, timezone_offset: Time.zone.formatted_offset|
    case System::Database.adapter.to_sym
    when :mysql
      coalesce(
        convert_tz(column, quoted('UTC'),    quoted(timezone_name)),
          convert_tz(column, quoted('+00:00'), quoted(timezone_offset))
      )
    when :postgres
      column.op('AT TIME ZONE', quoted('UTC')).op('AT TIME ZONE', quoted(timezone_name))
    when :oracle
      to_date(
        to_char(
          from_tz(
            cast(column.as('TIMESTAMP')), quoted('UTC') # First cast as timestamp
          ).op('AT TIME ZONE', quoted(timezone_name)), # Then use the timezone
            quoted('YYYY-MM-DD') # Remove the minutes and seconds
        ),
          quoted('YYYY-MM-DD HH24:MI:SS') # Reformat to be a valid date to compare with IN
      )
    end
  end

  module DatabaseUtilities
    module_function

    ORACLE_DATE_FORMAT_TRANSFORM = {
      '%Y' => 'YYYY',
      '%m' => 'MM',
      '%d' => 'DD',
      'T' => '"T"',
      '%H' => 'HH24',
    }.freeze

    def convert_to_oracle_date_format(format)
      return format if System::Database.mysql?

      ORACLE_DATE_FORMAT_TRANSFORM.reduce(format) do |str, (match, replacement)|
        str.sub(match, replacement)
      end
    end
  end
  private_constant :DatabaseUtilities

  sifter :date_format do |column, format|
    if System::Database.mysql?
      func(:date_format, column, quoted(format))
    else
      func(:to_char, column, quoted(DatabaseUtilities.convert_to_oracle_date_format(format)))
    end
  end

  sifter :desc do |field|
    System::Database.oracle? ? "#{field} DESC NULLS LAST" : {path: :desc}
  end

end
