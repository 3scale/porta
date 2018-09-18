require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class TimeFormatsTest < ActiveSupport::TestCase
  test 'compact' do
    assert_equal '20091103123455', Time.utc(2009, 11,  3, 12, 34, 55).to_s(:compact)
    assert_equal '200911031234',   Time.utc(2009, 11,  3, 12, 34,  0).to_s(:compact)
    assert_equal '2009110312',     Time.utc(2009, 11,  3, 12,  0,  0).to_s(:compact)
    assert_equal '20091103',       Time.utc(2009, 11,  3,  0,  0,  0).to_s(:compact)
    assert_equal '20091110',       Time.utc(2009, 11, 10,  0,  0,  0).to_s(:compact)
  end
end
