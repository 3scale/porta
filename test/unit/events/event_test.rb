require 'minitest_helper'

require 'events/event'

class Events::EventTest < MiniTest::Unit::TestCase
  def test_event_type
    event = Events::Event.new(type: 'alert')
    assert_equal 'alert', event.type
  end
end
