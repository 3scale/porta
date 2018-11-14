require 'test_helper'

class DateParsingTest < ActiveSupport::TestCase

  def test_parse_correct_date
    Timecop.freeze(Date.parse('2016-12-23')) do

      date = Time.zone.parse('2nd December, 1989')
      assert_equal 2, date.day
      assert_equal 12, date.month
      assert_equal 1989, date.year

      date = Time.zone.parse('2nd of December, 1989')
      assert_equal 1, date.day
      assert_equal 12, date.month
      assert_equal 1989, date.year
    end
  end
end
