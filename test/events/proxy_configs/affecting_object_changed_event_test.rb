# frozen_string_literal: true

require 'test_helper'

class ProxyConfigs::AffectingObjectChangedEventTest < ActiveSupport::TestCase
  test 'create' do
    proxy = FactoryBot.create(:proxy)
    proxy_rule = FactoryBot.build_stubbed(:proxy_rule, proxy: proxy)
    event = ProxyConfigs::AffectingObjectChangedEvent.create(proxy, proxy_rule)

    assert_equal proxy.id, event.proxy_id
    assert_equal proxy_rule.id, event.object_id
    assert_equal 'ProxyRule', event.object_type
  end

  test 'create_and_publish! persists when the proxy and the account are persisted and not scheduled_for_deletion' do
    proxy = FactoryBot.create(:proxy)
    proxy_rule = FactoryBot.build_stubbed(:proxy_rule, proxy: proxy)

    event = ProxyConfigs::AffectingObjectChangedEvent.create_and_publish!(proxy, proxy_rule)

    assert EventStore::Repository.find_event(event.event_id)
  end

  test 'create_and_publish! does not persist when the proxy is not present' do
    proxy_rule = FactoryBot.build_stubbed(:proxy_rule)

    refute ProxyConfigs::AffectingObjectChangedEvent.create_and_publish!(nil, proxy_rule)
  end

  test 'create_and_publish! does not persist when the account is not persisted' do
    proxy = FactoryBot.create(:proxy)
    proxy_rule = FactoryBot.build_stubbed(:proxy_rule, proxy: proxy)

    proxy.account.delete

    refute ProxyConfigs::AffectingObjectChangedEvent.create_and_publish!(proxy.reload, proxy_rule)
  end
  test 'create_and_publish! does not persist when the account is scheduled_for_deletion' do
    proxy = FactoryBot.create(:proxy)
    proxy_rule = FactoryBot.build_stubbed(:proxy_rule, proxy: proxy)

    proxy.account.schedule_for_deletion!

    refute ProxyConfigs::AffectingObjectChangedEvent.create_and_publish!(proxy, proxy_rule)
  end


end
