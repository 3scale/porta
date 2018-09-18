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
    if System::Database.oracle?
      to_date(
        to_char(
          from_tz(
            cast(column.as('TIMESTAMP')), quoted('UTC') # First cast as timestamp
          ).op('AT TIME ZONE', quoted(name)), # Then use the timezone
            quoted('YYYY-MM-DD') # Remove the minutes and seconds
        ),
          quoted('YYYY-MM-DD HH24:MI:SS') # Reformat to be a valid date to compare with IN
      )
    else
      coalesce(
        convert_tz(column, quoted('UTC'),    quoted(name)),
          convert_tz(column, quoted('+00:00'), quoted(offset))
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
      if System::Database.oracle?
        ORACLE_DATE_FORMAT_TRANSFORM.reduce(format) do |str, (match, replacement)|
          str.sub(match, replacement)
        end
      else
        format
      end
    end
  end
  private_constant :DatabaseUtilities

  sifter :date_format do |column, format|
    if System::Database.oracle?
      func(:to_char, column, quoted(DatabaseUtilities.convert_to_oracle_date_format(format)))
    else
      func(:date_format, column, quoted(format))
    end
  end
end
