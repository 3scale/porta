# frozen_string_literal: true

require 'test_helper'

class ApplicationDeletedEventTest < ActiveSupport::TestCase
  disable_transactional_fixtures!
  def setup
    @application = FactoryGirl.create(:cinstance)
  end

  attr_reader :application

  def test_create_and_publish_when_application_does_not_exists_anymore
    assert provider_id = application.provider_account.id
    application.provider_account.delete

    event = Applications::ApplicationDeletedEvent.create(application.reload)

    Rails.application.config.event_store.publish_event(event)

    event_stored = EventStore::Repository.find_event!(event.event_id)
    assert_equal provider_id, event_stored.metadata.fetch(:provider_id)
  end
end
