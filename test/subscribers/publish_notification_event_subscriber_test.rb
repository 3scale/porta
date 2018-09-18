require 'test_helper'

class PublishNotificationEventSubscriberTest < ActiveSupport::TestCase

  def setup
    @subscriber = PublishNotificationEventSubscriber.new(:some_name)
  end

  def test_create
    publisher = mock('publisher')
    publisher.expects(:call).with do |event|
      NotificationEvent === event
    end

    subscriber = PublishNotificationEventSubscriber.new(:some_name, publisher)
    provider = FactoryGirl.build_stubbed(:simple_provider)
    event = Class.new(RailsEventStore::Event).new(provider: provider)

    assert subscriber.call(event)
  end
end
