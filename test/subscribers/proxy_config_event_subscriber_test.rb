# frozen_string_literal: true

require 'test_helper'

class ProxyConfigEventSubscriberTest < ActiveSupport::TestCase
  test 'create' do
    proxy = FactoryBot.create(:proxy)
    proxy_rule = FactoryBot.build_stubbed(:proxy_rule, proxy: proxy)
    event = ProxyConfigs::AffectingObjectChangedEvent.create(proxy, proxy_rule)

    ProxyConfigAffectingChangeWorker.expects(:perform_later).with(event.event_id)

    ProxyConfigEventSubscriber.new.call(event)
  end
end
