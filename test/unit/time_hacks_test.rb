require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class TimeHacksTest < ActiveSupport::TestCase
  test 'beginning_of_cycle with duration' do
    assert_equal Time.utc(2009, 6, 11, 13, 00),
                 Time.utc(2009, 6, 11, 13, 45).beginning_of_cycle(1.hour)

    assert_equal Time.utc(2009, 6, 11, 13, 00),
                 Time.utc(2009, 6, 11, 13, 15).beginning_of_cycle(30.minutes)

    assert_equal Time.utc(2009, 6, 11, 13, 30),
                 Time.utc(2009, 6, 11, 13, 45).beginning_of_cycle(30.minutes)



    assert_equal Time.utc(2009, 6, 11, 00, 00),
                 Time.utc(2009, 6, 11, 13, 45).beginning_of_cycle(1.day)

    assert_equal Time.utc(2009, 6, 11, 00, 00),
                 Time.utc(2009, 6, 11,  4, 00).beginning_of_cycle(6.hours)

    assert_equal Time.utc(2009, 6, 11,  6, 00),
                 Time.utc(2009, 6, 11,  8, 00).beginning_of_cycle(6.hours)

    assert_equal Time.utc(2009, 6, 11, 12, 00),
                 Time.utc(2009, 6, 11, 14, 00).beginning_of_cycle(6.hours)
  end

  test 'beginning_of_cycle with symbol' do
    assert_equal Time.utc(2009, 6, 11, 13, 30),
                 Time.utc(2009, 6, 11, 13, 30, 29).beginning_of_cycle(:minute)

    assert_equal Time.utc(2009, 6, 11, 13, 00),
                 Time.utc(2009, 6, 11, 13, 30).beginning_of_cycle(:hour)

    assert_equal Time.utc(2009, 6, 11),
                 Time.utc(2009, 6, 11, 13, 30).beginning_of_cycle(:day)

    assert_equal Time.utc(2009, 6,  8),
                 Time.utc(2009, 6, 11, 13, 30).beginning_of_cycle(:week)

    assert_equal Time.utc(2009, 6,  1),
                 Time.utc(2009, 6, 11, 13, 30).beginning_of_cycle(:month)
  end

  test 'end_of_cycle with duration' do
    assert_equal Time.utc(2009, 6, 11, 13, 59, 59).at_end_of_minute,
                 Time.utc(2009, 6, 11, 13, 45).end_of_cycle(1.hour)

    assert_equal Time.utc(2009, 6, 11, 13, 29, 59).at_end_of_minute,
                 Time.utc(2009, 6, 11, 13, 15).end_of_cycle(30.minutes)

    assert_equal Time.utc(2009, 6, 11, 13, 59, 59).at_end_of_minute,
                 Time.utc(2009, 6, 11, 13, 45).end_of_cycle(30.minutes)



    assert_equal Time.utc(2009, 6, 11, 23, 59, 59).at_end_of_minute,
                 Time.utc(2009, 6, 11, 13, 45).end_of_cycle(1.day)

    assert_equal Time.utc(2009, 6, 11,  5, 59, 59).at_end_of_minute,
                 Time.utc(2009, 6, 11,  4, 00).end_of_cycle(6.hours)

    assert_equal Time.utc(2009, 6, 11, 11, 59, 59).at_end_of_minute,
                 Time.utc(2009, 6, 11,  8, 00).end_of_cycle(6.hours)

    assert_equal Time.utc(2009, 6, 11, 17, 59, 59).at_end_of_minute,
                 Time.utc(2009, 6, 11, 14, 00).end_of_cycle(6.hours)
  end

  test 'end_of_cycle with symbol' do
    assert_equal Time.utc(2009, 6, 11, 13, 30, 59).at_end_of_minute,
                 Time.utc(2009, 6, 11, 13, 30, 29).end_of_cycle(:minute)

    assert_equal Time.utc(2009, 6, 11, 13, 59, 59).at_end_of_minute,
                 Time.utc(2009, 6, 11, 13, 30).end_of_cycle(:hour)

    assert_equal Time.utc(2009, 6, 11).end_of_day,
                 Time.utc(2009, 6, 11, 13, 30).end_of_cycle(:day)

    assert_equal Time.utc(2009, 6, 11).end_of_week,
                 Time.utc(2009, 6, 11, 13, 30).end_of_cycle(:week)

    assert_equal Time.utc(2009, 6, 11).end_of_month,
                 Time.utc(2009, 6, 11, 13, 30).end_of_cycle(:month)
  end

  test 'beginning_of' do
    assert_equal Time.utc(2009, 6, 11, 13, 00),
                 Time.utc(2009, 6, 11, 13, 30).beginning_of(:hour)

    assert_equal Time.utc(2009, 6, 11),
                 Time.utc(2009, 6, 11, 13, 30).beginning_of(:day)

    assert_equal Time.utc(2009, 6,  8),
                 Time.utc(2009, 6, 11, 13, 30).beginning_of(:week)

    assert_equal Time.utc(2009, 6,  1),
                 Time.utc(2009, 6, 11, 13, 30).beginning_of(:month)
  end

  test 'end_of' do
    assert_equal Time.utc(2009, 6, 11, 13, 30, 59).at_end_of_minute,  Time.utc(2009, 6, 11, 13, 30).end_of(:minute)
    assert_equal Time.utc(2009, 6, 11, 13, 59, 59).at_end_of_minute,  Time.utc(2009, 6, 11, 13, 30).end_of(:hour)
    assert_equal Time.utc(2009, 6, 11).end_of_day,   Time.utc(2009, 6, 11, 13, 30).end_of(:day)
    assert_equal Time.utc(2009, 6, 11).end_of_week,  Time.utc(2009, 6, 11, 13, 30).end_of(:week)
    assert_equal Time.utc(2009, 6, 11).end_of_month, Time.utc(2009, 6, 11, 13, 30).end_of(:month)
  end
end
