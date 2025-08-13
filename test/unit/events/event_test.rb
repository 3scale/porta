# frozen_string_literal: true

require 'test_helper'

class Events::EventTest < SimpleMiniTest
  def test_event_type
    event = Events::Event.new(type: 'alert')
    assert_equal 'alert', event.type
  end
end
