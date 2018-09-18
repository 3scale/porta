require 'test_helper'

class Applications::ApplicationUpdatedEventTest < ActiveSupport::TestCase
  def test_create
    application = FactoryGirl.build_stubbed(:simple_cinstance)

    event = Applications::ApplicationUpdatedEvent.create(application)

    assert event
  end
end
