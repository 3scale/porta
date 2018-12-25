require 'test_helper'
class FindAndDeleteScheduledAccountsWorkerTest < ActiveSupport::TestCase
  def test_perform
    quiet_period_time = Account::States::PERIOD_BEFORE_DELETION
    FactoryBot.create_list(:simple_buyer, 2)
    FactoryBot.create_list(:simple_buyer, 3, state: 'scheduled_for_deletion', state_changed_at: quiet_period_time.ago)
    FactoryBot.create_list(:simple_provider, 4, state: 'scheduled_for_deletion', state_changed_at: quiet_period_time.ago)
    FactoryBot.create_list(:simple_provider, 1, state: 'scheduled_for_deletion', state_changed_at: quiet_period_time.ago + 1.day)
    assert_equal 7, Account.deleted_since.count
    DeleteAccountHierarchyWorker.expects(:perform_later).times(7)
    FindAndDeleteScheduledAccountsWorker.new.perform
  end
end
