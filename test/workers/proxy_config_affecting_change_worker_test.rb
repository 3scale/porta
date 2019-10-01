# frozen_string_literal: true

require 'test_helper'

class ProxyConfigAffectingChangeWorkerTest < ActiveSupport::TestCase
  setup do
    @worker = ProxyConfigAffectingChangeWorker.new
    EventStore::Repository.stubs(raise_errors: true)
  end

  attr_reader :worker

  test '#perform' do
    proxy = FactoryBot.create(:proxy)
    event = ProxyConfigs::AffectingObjectChangedEvent.create_and_publish!(proxy, mock(id: 123))

    affecting_change_history = mock
    Proxy.any_instance.expects(:create_proxy_config_affecting_change).returns(affecting_change_history)
    affecting_change_history.expects(:touch)

    worker.perform(event.event_id)
  end
end
