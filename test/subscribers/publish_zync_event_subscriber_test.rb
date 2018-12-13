require 'test_helper'

class PublishZyncEventSubscriberTest < ActiveSupport::TestCase
  def setup
    @subscriber = PublishZyncEventSubscriber.new
  end

  def test_create
    application = FactoryGirl.build_stubbed(:simple_cinstance, tenant_id: 1)
    event = Applications::ApplicationCreatedEvent.new(application: application)

    assert @subscriber.call(event)
  end
end
