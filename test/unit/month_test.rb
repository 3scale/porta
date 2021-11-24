# frozen_string_literal: true

require 'test_helper'

class MonthTest < ActiveSupport::TestCase
  def setup
    @first_of_february_2004 = Time.zone.local(2004,2,1).to_date
  end

  test 'initialize by first day' do
    month = Month.new(@first_of_february_2004)
    assert_equal Time.zone.local(2004, 2, 1).to_date, month.begin
    assert_equal Time.zone.local(2004, 2, 29).to_date, month.end
  end

  test 'initialize by year and day' do
    month = Month.new(2009,3)
    assert_equal Time.zone.local(2009, 3, 1).to_date, month.begin
    assert_equal Time.zone.local(2009, 3, 31).to_date, month.end
  end

  test 'initialize by first day and date arguments equally' do
    assert_equal Month.new(@first_of_february_2004), Month.new(2004,2)
  end

  test 'parse string' do
    m = Month.parse_month '2001-11'
    assert m.is_a?(Month)
    assert_equal m.begin.month, 11
    assert_equal m.begin.year, 2001
  end

  test 'parse not exactly right string' do
    assert_equal Month.new(2011, 0o1), Month.parse_month('2011-01-05')
  end

  test 'parse robustly' do
    assert_nil Month.parse_month nil
  end

  test 'return nil when parsing invalid date' do
    assert_nil Month.parse_month 'not-a-date'
    assert_nil Month.parse_month 'giberish'
  end

  test 'raise with wrong params' do
    assert_raises(ArgumentError) { Month.new('abcd') }
    assert_raises(ArgumentError) { Month.new(2001,2,1) }
  end

  test 'return correct next month' do
    assert_equal Month.new(2004,6), Month.new(2004,5).next
    assert_equal Month.new(2002,1), Month.new(2001,12).next
  end

  test '#to_time_range returns a TimeRange' do
    range = Month.new(2010, 11).to_time_range

    assert_equal Time.zone.local(2010, 11, 1), range.begin
    assert_equal Time.zone.local(2010, 11, 30).end_of_day, range.end
  end

  def test_i18_localize
    month = Month.new(2015, 0o6)

    assert_equal 'June 2015', I18n.l(month, format: :month)
  end

  test '#to_s' do
    month = Month.new(2015, 0o6)
    assert_equal 'June 01, 2015 - June 30, 2015', month.to_s
    assert_equal '2015-06-01', month.to_s(:db)
  end
end
