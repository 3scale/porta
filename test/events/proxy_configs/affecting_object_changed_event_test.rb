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
end
