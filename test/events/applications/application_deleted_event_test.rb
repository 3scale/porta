# frozen_string_literal: true

require 'test_helper'

class Applications::ApplicationDeletedEventTest < ActiveSupport::TestCase
  def setup
    @application = FactoryBot.create(:simple_cinstance)
    @service = application.service
  end

  attr_reader :application, :service

  def test_create_and_publish_when_the_application_associations_do_not_exist_anymore
    assert provider_id = application.provider_account.id
    service.proxy.destroy!
    service.delete
    application.provider_account.delete

    event = Applications::ApplicationDeletedEvent.create_and_publish!(application.reload)

    event_stored = EventStore::Repository.find_event!(event.event_id)
    assert_equal application.id, event_stored.application.id
    assert_equal service.backend_id, event_stored.service_backend_id
    assert_equal application.application_id, event_stored.application_id
    assert_equal provider_id, event_stored.metadata[:provider_id]
    assert_equal application.service_id, event_stored.metadata.dig(:zync, :service_id)
    assert event_stored.metadata[:zync].has_key?(:proxy_id)
    assert_nil event_stored.metadata.dig(:zync, :proxy_id)
  end
end
