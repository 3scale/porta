# frozen_string_literal: true

require 'test_helper'

class OIDC::ServiceChangedEventTest < ActiveSupport::TestCase

  def setup
    EventStore::Repository.stubs(raise_errors: true)
    @event_store = Rails.application.config.event_store
  end

  attr_reader :event_store

  def test_create
    service = FactoryBot.create(:simple_service)

    assert event = OIDC::ServiceChangedEvent.create(service)

    assert_equal :ok, event_store.publish_event(event)
  end
end
