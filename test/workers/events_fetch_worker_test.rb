# frozen_string_literal: true

require 'test_helper'

class EventsFetchWorkerTest < ActiveSupport::TestCase
  test '#perform' do
    Events.expects(:fetch_backend_events!).returns(true)
    EventsFetchWorker.new.perform
  end
end
