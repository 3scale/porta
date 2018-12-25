require 'test_helper'

class Account::StatesTest < ActiveSupport::TestCase
  test '.without_deleted' do
    accounts = FactoryBot.create_list(:simple_account, 2)
    accounts.first.schedule_for_deletion!

    ids_without_deleted = Account.without_deleted.pluck(:id)
    assert_not_includes ids_without_deleted, accounts.first.id
    assert_includes     ids_without_deleted, accounts.last.id

    ids_with_deleted = Account.without_deleted(false).pluck(:id)
    assert_includes ids_with_deleted, accounts.first.id
    assert_includes ids_with_deleted, accounts.last.id
  end

  def test_events_when_state_changed
    account = FactoryBot.create(:simple_account)

    Accounts::AccountStateChangedEvent.expects(:create)
                                      .with(account, 'approved').once

    PublishEnabledChangedEventForProviderApplicationsWorker
        .expects(:perform_later)
        .with(account, 'approved').once

    account.make_pending!
  end

  def test_events_when_state_not_changed
    account = FactoryBot.create(:simple_account)
    account.schedule_for_deletion!

    Accounts::AccountStateChangedEvent.expects(:create)
        .with(account, 'approved').never

    PublishEnabledChangedEventForProviderApplicationsWorker
        .expects(:perform_later)
        .with(account, 'approved').never

    account.schedule_for_deletion!
  end

  test 'new accounts are created as created' do
    account = Account.new
    assert account.created?
  end

  test 'approve! transitions from pending to approved' do
    account = FactoryBot.create(:pending_account)

    assert_change :of   => lambda { account.state },
                  :from => "pending",
                  :to   => "approved" do
      account.approve!
    end
  end

  test 'approve! transitions from rejected to approved' do
    account = FactoryBot.create(:pending_account)
    account.reject!

    assert_change :of   => lambda { account.state },
                  :from => "rejected",
                  :to   => "approved" do
      account.approve!
    end
  end

  # test 'upgrade state for buyer' do
  #
  #
  #
  #   def upgrade_state!
  #     if buyer?
  #       provider_account.service.approval_required? ? make_pending! : approve!
  #     else
  #       approve!
  #     end
  #   end
  #
  # end

  test 'sends notification email when account is made pending' do
    account = FactoryBot.create(:buyer_account_with_provider)
    account.make_pending!

    AccountMailer.any_instance.expects(:confirmed)
    account.send(:_run_after_commit_queue)
  end

  test 'sends notification email when account is rejected' do
    account = FactoryBot.create(:buyer_account_with_provider)
    account.reject!

    AccountMailer.any_instance.expects(:rejected)
    account.send(:_run_after_commit_queue)
  end

  test 'sends notification email when buyer account is approved' do
    account = FactoryBot.create(:buyer_account_with_provider)

    account.update_attribute(:state, 'pending')
    account.buy! FactoryBot.create(:account_plan, :approval_required => true)
    account.reload
    account.approve!

    AccountMailer.any_instance.expects(:approved)
    account.send(:_run_after_commit_queue)
  end

  test 'does not send notification email when non buyer account is approved' do
    AccountMailer.any_instance.expects(:approved).never

    account = FactoryBot.create(:pending_account)
    account.approve!

    account.send(:_run_after_commit_queue)
  end


  test 'suspend account' do
    account = Account.new(state: 'approved', domain: 'foo', self_domain: 'foobar', org_name: 'foo')
    account.provider_account = master_account

    assert_raise StateMachines::InvalidTransition do
      account.suspend!
    end

    refute account.suspended?

    account.provider = true
    account.suspend!

    assert_equal 'suspended', account.state
    assert account.suspended?
  end

  def test_suspend_master
    account = FactoryBot.build_stubbed(:simple_provider, master: true)
    assert_raise StateMachines::InvalidTransition do
      account.suspend!
    end
  end

  test 'resume account' do
    account = Account.new(state: 'suspended', domain: 'foo', self_domain: 'foobar', org_name: 'foo')
    account.provider_account = master_account

    assert_raise StateMachines::InvalidTransition do
      account.resume!
    end

    refute account.approved?

    account.provider = true
    account.resume!

    assert_equal 'approved', account.state
    assert account.approved?
  end

  test '.deleted_since' do
    accounts = FactoryBot.create_list(:simple_account, 3)

    account_deleted_recently = accounts[0]
    account_deleted_recently.schedule_for_deletion!
    account_deleted_recently.update_attribute(:state_changed_at, (Account::States::PERIOD_BEFORE_DELETION.ago + 1.day))

    account_deleted_long_ago = accounts[1]
    account_deleted_long_ago.schedule_for_deletion!
    account_deleted_long_ago.update_attribute(:state_changed_at, Account::States::PERIOD_BEFORE_DELETION.ago)

    account_not_deleted = accounts[2]

    results = Account.deleted_since.pluck(:id)
    assert_not_includes results, account_deleted_recently.id
    assert_includes     results, account_deleted_long_ago.id
    assert_not_includes results, account_not_deleted.id
  end

  test '.deletion_date' do
    account = FactoryBot.create(:simple_account)
    account.schedule_for_deletion!
    assert_equal Account::States::PERIOD_BEFORE_DELETION.from_now.to_date, account.deletion_date.to_date
  end

  test '.suspended_since' do
    FactoryBot.create(:simple_account, state: 'suspended')
    FactoryBot.create(:simple_account, state: 'approved')
    FactoryBot.create(:simple_account, state: 'suspended', state_changed_at: (Account::States::MAX_PERIOD_OF_SUSPENSION - 1.day).ago)
    account_suspended_antiquely = FactoryBot.create(:simple_account, state: 'suspended', state_changed_at: Account::States::MAX_PERIOD_OF_SUSPENSION.ago)
    assert_equal [account_suspended_antiquely.id], Account.suspended_since.pluck(:id)
  end

  test '.inactive_since' do
    old_account_without_traffic = FactoryBot.create(:simple_account)
    old_account_without_traffic.update_attribute(:created_at, Account::States::MAX_PERIOD_OF_INACTIVITY.ago)

    old_account_with_old_traffic = FactoryBot.create(:simple_account)
    old_account_with_old_traffic.update_attribute(:created_at, Account::States::MAX_PERIOD_OF_INACTIVITY.ago)
    FactoryBot.create(:cinstance, user_account: old_account_with_old_traffic, first_daily_traffic_at: Account::States::MAX_PERIOD_OF_INACTIVITY.ago)

    recent_account_without_traffic = FactoryBot.create(:simple_account)
    recent_account_without_traffic.update_attribute(:created_at, (Account::States::MAX_PERIOD_OF_INACTIVITY - 1.day).ago)
    FactoryBot.create(:cinstance, user_account: recent_account_without_traffic, first_daily_traffic_at: (Account::States::MAX_PERIOD_OF_INACTIVITY - 1.day).ago)

    recent_account_with_recent_traffic = FactoryBot.create(:simple_account)
    recent_account_with_recent_traffic.update_attribute(:created_at, Account::States::MAX_PERIOD_OF_INACTIVITY.ago)
    FactoryBot.create(:cinstance, user_account: recent_account_with_recent_traffic, first_daily_traffic_at: (Account::States::MAX_PERIOD_OF_INACTIVITY - 1.day).ago)

    results = Account.inactive_since.pluck(:id)
    assert_includes     results, old_account_without_traffic.id
    assert_includes     results, old_account_with_old_traffic.id
    assert_not_includes results, recent_account_without_traffic.id
    assert_not_includes results, recent_account_with_recent_traffic.id
  end

  test '.without_traffic_since' do
    account_without_traffic = FactoryBot.create(:simple_account)

    account_with_old_traffic = FactoryBot.create(:simple_account)
    FactoryBot.create(:cinstance, user_account: account_with_old_traffic, first_daily_traffic_at: Account::States::MAX_PERIOD_OF_INACTIVITY.ago)

    account_with_recent_traffic = FactoryBot.create(:simple_account)
    FactoryBot.create(:cinstance, user_account: account_with_recent_traffic, first_daily_traffic_at: (Account::States::MAX_PERIOD_OF_INACTIVITY - 1.day).ago)

    results = Account.without_traffic_since.pluck(:id)
    assert_includes     results, account_without_traffic.id
    assert_includes     results, account_with_old_traffic.id
    assert_not_includes results, account_with_recent_traffic.id
  end


  class CallbacksTest < ActiveSupport::TestCase
    disable_transactional_fixtures!

    def test_suspend
      account = FactoryBot.create(:provider_account)

      ThreeScale::Analytics.expects(:track).with(account.first_admin, 'Account Suspended')
      ReverseProviderKeyWorker.expects(:enqueue).with(account)

      assert account.suspend!
    end

    def test_resume_from_suspended
      account = FactoryBot.create(:provider_account)
      account.update_columns(state: 'suspended')

      ThreeScale::Analytics.expects(:track).with(account.first_admin, 'Account Resumed')
      ReverseProviderKeyWorker.expects(:enqueue).with(account)

      assert account.resume!
    end

    def test_resume_from_scheduled_for_deletion
      account = FactoryBot.create(:simple_provider)
      account.schedule_for_deletion!

      BackendProviderSyncWorker.expects(:enqueue).with(account.id)

      account.resume!
    end

    def test_schedule_for_deletion
      account = FactoryBot.create(:simple_provider)
      refute account.scheduled_for_deletion?

      BackendProviderSyncWorker.expects(:enqueue).with(account.id)

      account.schedule_for_deletion!
    end

    def test_state_changed_at_from_any_to_any
      account = FactoryBot.create(:simple_provider, state: :created)

      %i[make_pending! reject! approve! suspend! resume! schedule_for_deletion!].each do |transition|
        Timecop.freeze do
          account.public_send(transition)
          assert_equal Time.zone.now.to_s, account.reload.state_changed_at.to_s
          assert_equal Time.zone.now.to_s, account.reload.deleted_at.to_s
        end
      end
    end

  end
end
