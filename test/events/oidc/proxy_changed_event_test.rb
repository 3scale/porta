# frozen_string_literal: true

require 'test_helper'

class OIDC::ProxyChangedEventTest < ActiveSupport::TestCase
  def setup
    EventStore::Repository.stubs(raise_errors: true)
    @event_store = Rails.application.config.event_store
  end

  attr_reader :event_store

  def test_create_and_publish!
    proxy = FactoryBot.create(:simple_proxy, oidc_issuer_endpoint: 'http://example.com/auth/realm')
    refute OIDC::ProxyChangedEvent.create_and_publish!(proxy), 'service is not oauth'

    proxy.service.backend_version = 'oauth'
    assert_equal :ok, OIDC::ProxyChangedEvent.create_and_publish!(proxy),'event should be created for OAuth service'
  end

  def test_create
    proxy = FactoryBot.build_stubbed(:simple_proxy, oidc_issuer_endpoint: 'http://example.com/auth/realm')
    assert OIDC::ProxyChangedEvent.create(proxy)

    proxy.service.backend_version = 'oauth'
    assert event = OIDC::ProxyChangedEvent.create(proxy),'event should be created for OAuth service'
    zync = event.metadata.fetch(:zync)
    assert_equal 'http://example.com/auth/realm', zync[:oidc_endpoint]
    assert_equal proxy.service.id, zync[:service_id]
  end
end
