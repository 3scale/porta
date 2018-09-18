require 'test_helper'

class PurgeOldUserSessionsWorkerTest < ActiveSupport::TestCase
  def setup
    ThreeScale.config.stubs(janitor_worker_enabled: true)
    UserSession.delete_all
    UserSession.create!(user_id: 1, key: 'key1', revoked_at: 1.month.ago)
    UserSession.create!(user_id: 2, key: 'key2', accessed_at: 3.weeks.ago)
    UserSession.create!(user_id: 3, key: 'key3', accessed_at: 1.week.ago)
  end

  def test_perform
    PurgeOldUserSessionsWorker.new.perform
    assert_equal 2, UserSessionSweeperWorker.jobs.size
  end
end
