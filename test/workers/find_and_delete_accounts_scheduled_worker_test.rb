require 'test_helper'
class FindAndDeleteScheduledAccountsWorkerTest < ActiveSupport::TestCase
  def setup
    quiet_period_time = Account::States::PERIOD_BEFORE_DELETION
    FactoryBot.create_list(:simple_buyer, 2)
    FactoryBot.create_list(:simple_buyer, 3, state: 'scheduled_for_deletion', state_changed_at: quiet_period_time.ago)
    FactoryBot.create_list(:simple_provider, 4, state: 'scheduled_for_deletion', state_changed_at: quiet_period_time.ago)
    FactoryBot.create_list(:simple_provider, 1, state: 'scheduled_for_deletion', state_changed_at: quiet_period_time.ago + 1.day)
  end

  def test_perform
    ThreeScale.config.stubs(onpremises: true)
    DeleteAccountHierarchyWorker.expects(:perform_later).times(7)
    FindAndDeleteScheduledAccountsWorker.new.perform
  end
end
