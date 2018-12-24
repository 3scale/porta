# frozen_string_literal: true

require 'test_helper'

class PurgeOldEventsWorkerTest < ActiveSupport::TestCase
  def setup
    Timecop.freeze(EventStore::Event::TTL.ago) { FactoryBot.create(:service_token) }
  end

  def test_perform
    DeletePlainObjectWorker.expects(:perform_later).with(instance_of(EventStore::Event)).times(EventStore::Event.stale.count)
    PurgeOldEventsWorker.new.perform
  end
end
