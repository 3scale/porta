require 'test_helper'

class ServiceTokenDeletedEventTest < ActiveSupport::TestCase
  disable_transactional_fixtures!
  def setup
    @service_token = FactoryGirl.create(:service_token)
  end

  attr_reader :service_token

  def test_create
    event = ServiceTokenDeletedEvent.create(service_token)

    assert service_token.attributes.slice('id', 'service_id', 'value').symbolize_keys, event.data
  end

  def test_subscribed
    ServiceTokenEventSubscriber.any_instance.expects(:call).with(instance_of(ServiceTokenDeletedEvent))
    service_token.destroy!
  end

  def test_create_and_publish_when_service_does_not_exists_anymore
    assert provider_id = service_token.service.account.id
    service_token.service.delete

    event = ServiceTokenDeletedEvent.create(service_token.reload)

    Rails.application.config.event_store.publish_event(event)

    event_stored = EventStore::Repository.find_event!(event.event_id)
    assert_equal provider_id, event_stored.metadata.fetch(:provider_id)
  end
end
