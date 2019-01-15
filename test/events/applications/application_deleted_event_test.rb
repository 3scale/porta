# frozen_string_literal: true

require 'test_helper'

class Applications::ApplicationDeletedEventTest < ActiveSupport::TestCase
  disable_transactional_fixtures!
  def setup
    @application = FactoryBot.create(:cinstance)
  end

  attr_reader :application

  def test_create_and_publish_when_the_application_associations_do_not_exist_anymore
    assert provider_id = application.provider_account.id
    application.service.proxy.destroy!
    application.service.delete
    application.provider_account.delete

    event = Applications::ApplicationDeletedEvent.create(application.reload)
    Rails.application.config.event_store.publish_event(event)

    event_stored = EventStore::Repository.find_event!(event.event_id)
    assert_equal provider_id, event_stored.metadata[:provider_id]
    assert event_stored.metadata.dig(:zync, :service_id)
    assert event_stored.metadata[:zync].has_key?(:proxy_id)
    assert_nil event_stored.metadata.dig(:zync, :proxy_id)
  end
end
