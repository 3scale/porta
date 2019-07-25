# frozen_string_literal: true

require 'test_helper'

class Domains::ProxyDomainsChangedEventTest < ActiveSupport::TestCase
  test 'deserialises correctly when the Proxy is deleted' do
    proxy = FactoryBot.create(:simple_proxy)
    event = Domains::ProxyDomainsChangedEvent.create_and_publish!(proxy)

    proxy.delete

    assert EventStore::Repository.find_event(event.event_id)
  end
end
