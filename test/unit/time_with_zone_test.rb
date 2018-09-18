require 'test_helper'

class TimeWithZoneTest < ActiveSupport::TestCase

  test 'as_json should not include miliseconds' do
    assert_equal '2010-01-01T00:00:00Z', Time.zone.local(2010).as_json
  end
end
