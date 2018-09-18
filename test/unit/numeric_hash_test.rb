require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class NumericHashTest < ActiveSupport::TestCase
  test 'update with numeric hash' do
    usage_one = NumericHash.new(42 => 1, 43 => 2)
    usage_two = NumericHash.new(42 => 3, 44 => 4)

    result = usage_one.update(usage_two)

    assert_instance_of NumericHash, result
    assert_same result, usage_one
    assert_equal NumericHash.new(42 => 3, 43 => 2, 44 => 4), usage_one
  end

  test 'update with hash' do
    usage = NumericHash.new(42 => 1)
    result = usage.update(43 => 2)

    assert_instance_of NumericHash, result
    assert_same result, usage
    assert_equal NumericHash.new(42 => 1, 43 => 2), usage
  end

  test '+' do
    usage_one = NumericHash.new(42 => 2, 43 => 3)
    usage_two = NumericHash.new(42 => 1)

    assert_equal NumericHash.new(42 => 3, 43 => 3), usage_one + usage_two
    assert_equal NumericHash.new(42 => 3, 43 => 3), usage_two + usage_one
  end

  test '-' do
    usage_one = NumericHash.new(42 => 2, 43 => 3)
    usage_two = NumericHash.new(42 => 1)

    assert_equal NumericHash.new(42 => 1, 43 => 3), usage_one - usage_two
    assert_equal NumericHash.new(42 => -1, 43 => -3), usage_two - usage_one
  end

  test 'map' do
    usage = NumericHash.new(42 => 1, 43 => 2)

    assert_same_elements([[42, 1], [43, 2]], usage.map { |key, value| [key, value] })
  end

  test '[]' do
    usage = NumericHash.new(42 => 1, 43 => 2)

    assert_equal 1, usage[42]
    assert_equal 2, usage[43]
    assert_nil usage[44]
  end

  test 'blank?' do
    assert  NumericHash.new.blank?
    assert !NumericHash.new(42 => 1).blank?
  end

  test 'reset!' do
    usage = NumericHash.new(42 => 1)
    usage.reset!

    assert usage.blank?
  end

  test 'nonzero?' do
    assert !NumericHash.new.nonzero?
    assert !NumericHash.new(41 => 0, 42 => 0).nonzero?
    assert  NumericHash.new(42 => 1).nonzero?
  end
end
