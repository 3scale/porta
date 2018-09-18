require 'test_helper'
class UserSessionSweeperWorkerTest < MiniTest::Unit::TestCase
  def setup
    @session = UserSession.create!(user_id: 1, key: 'secret', revoked_at: 1.month.ago)
  end

  def test_perform
    Sidekiq::Testing.inline! do
      assert @session.present?

      UserSessionSweeperWorker.perform_async(@session.id)

      assert_raises(ActiveRecord::RecordNotFound) do
        @session.reload
      end
    end
  end
end
