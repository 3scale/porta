require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class StringHacksTest < ActiveSupport::TestCase
  test '#from_sentence with empty string returns empty array' do
    assert_equal [], "".from_sentence
    assert_equal [], "   ".from_sentence
  end

  test '#from_sentence with one word returns array the word as single element' do
    assert_equal ['alice'], "alice".from_sentence
  end

  test '#from_sentence with two words separated by "and" returns array of those two words' do
    assert_equal ['alice', 'bob'], "alice and bob".from_sentence
  end

  test '#from_sentence with two words separated by "," returns array of those two words' do
    assert_equal ['alice', 'bob'], "alice, bob".from_sentence
  end

  test '#from_sentence with more than two words returns array of all the words' do
    assert_equal ['alice', 'bob', 'claire'], "alice, bob and claire".from_sentence
    assert_equal ['alice', 'bob', 'claire'], "alice, bob, claire".from_sentence
    assert_equal ['alice', 'bob', 'claire'], "alice and bob and claire".from_sentence
  end

  test '#from_sentence handles comma followed by "and" as a single separator' do
    assert_equal ['alice', 'bob'], "alice, and bob".from_sentence
  end

  test '#from_sentence does not tread "and" in the middle of a word as separator' do
    assert_equal ['sandra'], "sandra".from_sentence
  end

  test 'String#from_sentence is inverse of Array#to_sentence' do
    array = ['alice', 'bob', 'claire', 'david']

    assert_equal array, array.to_sentence.from_sentence
  end
end
