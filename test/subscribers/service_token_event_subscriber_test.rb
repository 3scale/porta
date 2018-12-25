require 'test_helper'

class ServiceTokenEventSubscriberTest < ActiveSupport::TestCase
  def test_create
    service_token = FactoryBot.build_stubbed(:service_token)
    event = ServiceTokenDeletedEvent.create(service_token)

    BackendDeleteServiceTokenWorker.expects(:enqueue).with(event)

    ServiceTokenEventSubscriber.new.after_commit(event)
  end
end
