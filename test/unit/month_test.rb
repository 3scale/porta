require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class MonthTest < ActiveSupport::TestCase

  context 'Month' do
    setup do
      @first_of_february_2004 = Time.zone.local(2004,2,1).to_date
    end

    should 'initialize by first day' do
      month = Month.new(@first_of_february_2004)
      assert_equal Time.zone.local(2004, 2, 1).to_date, month.begin
      assert_equal Time.zone.local(2004, 2, 29).to_date, month.end
    end

    should 'initialize by year and day' do
      month = Month.new(2009,3)
      assert_equal Time.zone.local(2009, 3, 1).to_date, month.begin
      assert_equal Time.zone.local(2009, 3, 31).to_date, month.end
    end

    should 'initialize by first day and date arguments equally' do
      assert_equal Month.new(@first_of_february_2004), Month.new(2004,2)
    end

    should 'parse string' do
      m = Month.parse_month '2001-11'
      assert m.is_a?(Month)
      assert_equal m.begin.month, 11
      assert_equal m.begin.year, 2001
    end

    should 'parse not exactly right string' do
      assert_equal Month.new(2011, 01), Month.parse_month('2011-01-05')
    end

    should 'parse robustly' do
      assert_nil Month.parse_month nil
    end

    should 'return nil when parsing invalid date' do
      assert_nil Month.parse_month 'not-a-date'
      assert_nil Month.parse_month 'giberish'
    end

    should 'raise with wrong params' do
      wrong = stub
      assert_raises(ArgumentError) { Month.new(wrong) }
      assert_raises(ArgumentError) { Month.new(2001,2,1) }
    end

    should 'return correct next month' do
      assert_equal Month.new(2004,6), Month.new(2004,5).next
      assert_equal Month.new(2002,1), Month.new(2001,12).next
    end
  end

  test '#to_time_range returns a TimeRange' do
    range = Month.new(2010, 11).to_time_range

    assert_equal Time.zone.local(2010, 11, 1), range.begin
    assert_equal Time.zone.local(2010, 11, 30).end_of_day, range.end
  end


  def test_i18_localize
    month = Month.new(2015, 06)

    assert_equal 'June 2015', I18n.localize(month, format: :month)
  end
end
