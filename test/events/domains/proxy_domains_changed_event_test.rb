# frozen_string_literal: true

require 'test_helper'

class Domains::ProxyDomainsChangedEventTest < ActiveSupport::TestCase
  test 'deserialises correctly when the Proxy is deleted' do
    proxy = FactoryBot.create(:proxy)
    event = Domains::ProxyDomainsChangedEvent.create(proxy)
    Rails.application.config.event_store.publish_event(event)

    proxy.delete

    assert EventStore::Repository.find_event(event.event_id)
  end
end
