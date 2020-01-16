# frozen_string_literal: true

require 'test_helper'

class Domains::ProxyDomainsChangedEventTest < ActiveSupport::TestCase
  setup do
    @proxy = FactoryBot.create(:simple_proxy)
  end

  attr_reader :proxy

  test 'deserialises correctly when the Proxy is deleted' do
    event = Domains::ProxyDomainsChangedEvent.create_and_publish!(proxy)

    proxy.delete

    assert EventStore::Repository.find_event(event.event_id)
  end

  test 'invalid is missing provider' do
    assert Domains::ProxyDomainsChangedEvent.create_and_publish!(proxy)
    proxy.provider.delete
    refute Domains::ProxyDomainsChangedEvent.create_and_publish!(proxy)
  end
end
