require 'test_helper'

class JanitorWorkerTest < ActiveSupport::TestCase
  def test_perform
    ThreeScale.config.stubs(janitor_worker_enabled: true)
    PurgeOldUserSessionsWorker.expects(:perform_async).once
    PurgeOldEventsWorker.expects(:perform_async).once
    JanitorWorker.new.perform
  end

  def test_not_enabled
    ThreeScale.config.stubs(janitor_worker_enabled: false)
    PurgeOldUserSessionsWorker.expects(:perform_async).never
    PurgeOldEventsWorker.expects(:perform_async).never
    JanitorWorker.new.perform
  end
end
