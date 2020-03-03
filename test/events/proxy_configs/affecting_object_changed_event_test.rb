# frozen_string_literal: true

require 'test_helper'

class ProxyConfigs::AffectingObjectChangedEventTest < ActiveSupport::TestCase
  test 'create_and_publish! persists with the right data when the proxy and the account are persisted and not scheduled_for_deletion' do
    stored_event = EventStore::Repository.find_event!(event_published.event_id)

    assert_equal proxy.id, stored_event.proxy_id
    assert_equal proxy_rule.id, stored_event.object_id
    assert_equal 'ProxyRule', stored_event.object_type
  end

  test 'create_and_publish! does not persist when the proxy is not present' do
    refute event_published(proxy: nil)
  end

  test 'create_and_publish! does not persist when the account is not persisted' do
    proxy.account.delete

    refute event_published
  end
  test 'create_and_publish! does not persist when the account is scheduled_for_deletion' do
    proxy.account.schedule_for_deletion!

    refute event_published
  end

  private

  def proxy_rule
    @proxy_rule ||= FactoryBot.build_stubbed(:proxy_rule, proxy: proxy)
  end

  def proxy
    @proxy ||= FactoryBot.create(:proxy)
  end

  def event_published(proxy: proxy_rule.proxy)
    @event_published ||= ProxyConfigs::AffectingObjectChangedEvent.create_and_publish!(proxy&.reload, proxy_rule)
  end
end
