require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class RangeHacksTest < ActiveSupport::TestCase
  test 'subinterval with uniform partitioning' do
    range = 1..10
    assert_equal 1..5,  range.subinterval(0, 2)
    assert_equal 6..10, range.subinterval(1, 2)

    range = 1..15
    assert_equal 1..5,   range.subinterval(0, 3)
    assert_equal 6..10,  range.subinterval(1, 3)
    assert_equal 11..15, range.subinterval(2, 3)

    range = 101..1000
    assert_equal 101..325,  range.subinterval(0, 4)
    assert_equal 326..550,  range.subinterval(1, 4)
    assert_equal 551..775,  range.subinterval(2, 4)
    assert_equal 776..1000, range.subinterval(3, 4)
  end

  test 'subinterval with non-uniform partitioning' do
    range = 1..10
    assert_equal 1..3,  range.subinterval(0, 3)
    assert_equal 4..6,  range.subinterval(1, 3)
    assert_equal 7..10, range.subinterval(2, 3)

    range = 1..15
    assert_equal 1..3,   range.subinterval(0, 4)
    assert_equal 4..6,   range.subinterval(1, 4)
    assert_equal 7..9,  range.subinterval(2, 4)
    assert_equal 10..15, range.subinterval(3, 4)

    range = 101..1000
    assert_equal 101..228,  range.subinterval(0, 7)
    assert_equal 229..356,  range.subinterval(1, 7)
    assert_equal 357..484,  range.subinterval(2, 7)
    assert_equal 485..612,  range.subinterval(3, 7)
    assert_equal 613..740,  range.subinterval(4, 7)
    assert_equal 741..868,  range.subinterval(5, 7)
    assert_equal 869..1000, range.subinterval(6, 7)
  end
end
