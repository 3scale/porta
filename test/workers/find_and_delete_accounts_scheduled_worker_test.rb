require 'test_helper'
class FindAndDeleteScheduledAccountsWorkerTest < ActiveSupport::TestCase
  def test_perform
    FactoryGirl.create_list(:simple_buyer, 2)
    FactoryGirl.create_list(:simple_buyer, 3, state: 'scheduled_for_deletion', deleted_at: 15.days.ago)
    FactoryGirl.create_list(:simple_provider, 4, state: 'scheduled_for_deletion', deleted_at: 15.days.ago)
    FactoryGirl.create_list(:simple_provider, 1, state: 'scheduled_for_deletion', deleted_at: 14.days.ago)
    assert_equal 7, Account.deleted_time_ago.count
    DeleteAccountHierarchyWorker.expects(:perform_later).times(7)
    FindAndDeleteScheduledAccountsWorker.new.perform
  end
end
