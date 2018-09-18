require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class NumericHacksTest < ActiveSupport::TestCase
  test 'percentage_change_from' do
    assert_equal 0,     0.percentage_change_from(0)
    assert_equal 100.0, 1.percentage_change_from(0)
    assert_equal 50.0,  3.percentage_change_from(2)
    assert_equal 100.0, 2.percentage_change_from(1)
    assert_equal -50.0, 2.percentage_change_from(4)
  end

  test 'percentage_ratio_of' do
    assert_equal 0,     0.percentage_ratio_of(0)
    assert_equal 0,     0.percentage_ratio_of(10)
    assert_equal 10.0,  1.percentage_ratio_of(10)
    assert_equal 50.0,  5.percentage_ratio_of(10)
    assert_equal 200.0, 20.percentage_ratio_of(10)
  end
end
