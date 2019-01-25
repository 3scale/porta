# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true


  sifter(:month_number) do |column|
    if System::Database.mysql?
      func(:month, column)
    else
      func(:to_number, func(:to_char, column, quoted('MM')))
    end
  end

  sifter(:year) do |column|
    if System::Database.mysql?
      func(:year, column)
    else
      func(:to_number, func(:to_char, column, quoted('YYYY')))
    end
  end

  sifter :date do |column|
    name = System::Database.oracle? ? :trunc : :date

    func(name, column)
  end

  sifter :in_timezone do |column, zone = Time.zone, name: zone.tzinfo.name, offset: zone.formatted_offset|
    case System::Database.adapter.to_sym
    when :mysql
      coalesce(
        convert_tz(column, quoted('UTC'),    quoted(name)),
          convert_tz(column, quoted('+00:00'), quoted(offset))
      )
    when :postgres
      column.op('AT TIME ZONE', quoted('UTC')).op('AT TIME ZONE', quoted(name))
    when :oracle
      to_date(
        to_char(
          from_tz(
            cast(column.as('TIMESTAMP')), quoted('UTC') # First cast as timestamp
          ).op('AT TIME ZONE', quoted(name)), # Then use the timezone
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
end
