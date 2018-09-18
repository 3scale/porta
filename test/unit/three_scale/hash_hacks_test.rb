require 'test_helper'

class HashKeysCaseConversionsTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "plugin is loaded" do
    hash = {}

    assert_respond_to hash, :downcase_keys
    assert_respond_to hash, :downcase_keys!

    assert_respond_to hash, :upcase_keys
    assert_respond_to hash, :upcase_keys!
  end

  test 'downcase_keys' do
    hash = {'Foo' => 1, 'BAR' => 2}
    assert_equal({'foo' => 1, 'bar' => 2}, hash.downcase_keys)
    assert_equal({'Foo' => 1, 'BAR' => 2}, hash)
  end

  test 'downcase_keys!' do
    hash = {'Foo' => 1, 'BAR' => 2}
    hash.downcase_keys!

    assert_equal({'foo' => 1, 'bar' => 2}, hash)
  end

  test 'upcase_keys' do
    hash = {'foo' => 1, 'Bar' => 2}
    assert_equal({'FOO' => 1, 'BAR' => 2}, hash.upcase_keys)
    assert_equal({'foo' => 1, 'Bar' => 2}, hash)
  end

  test 'upcase_keys!' do
    hash = {'Foo' => 1, 'BAR' => 2}
    hash.upcase_keys!

    assert_equal({'FOO' => 1, 'BAR' => 2}, hash)
  end

  test 'map_values' do
    hash_one = {'foo' => 1, 'bar' => 2}
    hash_two = hash_one.map_values { |value| value + 1 }

    assert_equal({'foo' => 1, 'bar' => 2}, hash_one)
    assert_equal({'foo' => 2, 'bar' => 3}, hash_two)
  end

  test 'map_values!' do
    hash = {'foo' => 1, 'bar' => 2}
    hash.map_values! { |value| value + 1 }

    assert_equal({'foo' => 2, 'bar' => 3}, hash)
  end

  test 'map_keys' do
    hash_one = {'foo' => 1, 'bar' => 2}
    hash_two = hash_one.map_keys { |value| value + '!' }

    assert_equal({'foo' => 1, 'bar' => 2}, hash_one)
    assert_equal({'foo!' => 1, 'bar!' => 2}, hash_two)
  end

  test 'map_keys!' do
    hash = {'foo' => 1, 'bar' => 2}
    hash.map_keys! { |key| key + '!' }

    assert_equal({'foo!' => 1, 'bar!' => 2}, hash)
  end

  test 'sort_keys' do
    hash = ActiveSupport::OrderedHash.new
    hash[42] = 'foo'
    hash[12] = 'bar'

    expected = ActiveSupport::OrderedHash.new
    expected[12] = 'bar'
    expected[42] = 'foo'

    assert_equal expected, hash.sort_keys
  end
end
