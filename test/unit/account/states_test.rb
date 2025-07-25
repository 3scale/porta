require 'test_helper'

class Account::StatesTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test '.without_suspended' do
    accounts = FactoryBot.create_list(:simple_provider, 2)
    accounts.first.suspend!

    ids_without_suspended = Account.without_suspended.pluck(:id)
    assert_not_includes ids_without_suspended, accounts.first.id
    assert_includes ids_without_suspended, accounts.last.id
  end

  test '.without_deleted' do
    accounts = FactoryBot.create_list(:simple_account, 2)
    accounts.first.schedule_for_deletion!

    ids_without_deleted = Account.without_deleted.pluck(:id)
    assert_not_includes ids_without_deleted, accounts.first.id
    assert_includes ids_without_deleted, accounts.last.id

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

    assert_change :of => -> { account.state },
                  :from => "pending",
                  :to => "approved" do
      account.approve!
    end
  end

  test 'approve! transitions from rejected to approved' do
    account = FactoryBot.create(:pending_account)
    account.reject!

    assert_change :of => -> { account.state },
                  :from => "rejected",
                  :to => "approved" do
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

  test 'enqueues notification email when account is made pending' do
    account = FactoryBot.create(:buyer_account)
    assert_enqueued_email_with(AccountMailer, :confirmed, args: [account]) do
      account.make_pending!
    end
  end

  test 'enqueues notification email when account is rejected' do
    account = FactoryBot.create(:buyer_account)
    assert_enqueued_email_with(AccountMailer, :rejected, args: [account]) do
      account.reject!
    end
  end

  test 'enqueues notification email when buyer account is approved' do
    account = FactoryBot.create(:buyer_account)

    account.update_attribute(:state, 'pending')
    account.buy! FactoryBot.create(:account_plan, :approval_required => true)
    account.reload

    assert_enqueued_email_with(AccountMailer, :approved, args: [account]) do
      account.approve!
    end

  end

  test 'does not enqueue notification email when non buyer account is approved' do
    AccountMailer.any_instance.expects(:approved).never

    account = FactoryBot.create(:pending_account)
    assert_no_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
      account.approve!
    end
  end

  %w[provider buyer].each do |account_type|
    test "suspend #{account_type} account" do
      account = Account.new(state: 'approved', domain: 'foo', self_domain: 'foobar', org_name: 'foo')
      account.provider_account = master_account
      account.provider = account_type == 'provider'
      account.buyer = !account.provider?

      account.suspend!

      assert_equal 'suspended', account.state
      assert account.suspended?
    end

    test "resume #{account_type} account" do
      account = Account.new(state: 'suspended', domain: 'foo', self_domain: 'foobar', org_name: 'foo')
      account.provider_account = master_account
      account.provider = account_type == 'provider'

      account.resume!

      assert_equal 'approved', account.state
      assert account.approved?
    end
  end

  def test_suspend_master
    account = FactoryBot.build_stubbed(:simple_provider, master: true)
    assert_raise StateMachines::InvalidTransition do
      account.suspend!
    end
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
    assert_includes results, account_deleted_long_ago.id
    assert_not_includes results, account_not_deleted.id
  end

  test '.deletion_date' do
    account = FactoryBot.create(:simple_account)
    account.schedule_for_deletion!
    assert_equal Account::States::PERIOD_BEFORE_DELETION.from_now.to_date, account.deletion_date.to_date
  end

  test '.suspended_since' do
    suspended_since_days = 5.days
    FactoryBot.create(:simple_account, state: 'suspended')
    FactoryBot.create(:simple_account, state: 'approved')
    FactoryBot.create(:simple_account, state: 'suspended', state_changed_at: (suspended_since_days - 1.day).ago)
    account_suspended_antiquely = FactoryBot.create(:simple_account, state: 'suspended', state_changed_at: suspended_since_days.ago)
    assert_raise(ArgumentError) { Account.suspended_since.pluck(:id) }
    assert_equal [account_suspended_antiquely.id], Account.suspended_since(suspended_since_days.ago).pluck(:id)
  end

  test '.inactive_since' do
    inactive_period_start = 5.days.ago
    provider = FactoryBot.create(:provider_account)

    old_account_without_traffic = FactoryBot.create(:buyer_account, provider_account: provider)
    old_account_without_traffic.update_attribute(:created_at, inactive_period_start)

    old_account_with_old_traffic = FactoryBot.create(:buyer_account, provider_account: provider)
    old_account_with_old_traffic.update_attribute(:created_at, inactive_period_start)
    FactoryBot.create(:cinstance, user_account: old_account_with_old_traffic, first_daily_traffic_at: inactive_period_start - 1)

    recent_account_without_traffic = FactoryBot.create(:buyer_account, provider_account: provider)
    recent_account_without_traffic.update_attribute(:created_at, inactive_period_start + 1)
    old_account_with_recent_traffic = FactoryBot.create(:buyer_account, provider_account: provider)
    old_account_with_recent_traffic.update_attribute(:created_at, inactive_period_start)
    FactoryBot.create(:cinstance, user_account: old_account_with_recent_traffic, first_daily_traffic_at: inactive_period_start)

    assert_raise(ArgumentError) { Account.inactive_since.pluck(:id) }
    results = Account.inactive_since(inactive_period_start).pluck(:id)
    assert_includes results, old_account_without_traffic.id
    assert_includes results, old_account_with_old_traffic.id
    assert_not_includes results, recent_account_without_traffic.id
    assert_not_includes results, old_account_with_recent_traffic.id
  end

  test '.without_traffic_since' do
    inactive_since_days = 5.days

    account_without_traffic = FactoryBot.create(:simple_account)

    account_with_old_traffic = FactoryBot.create(:buyer_account)
    FactoryBot.create(:cinstance, user_account: account_with_old_traffic, first_daily_traffic_at: inactive_since_days.ago - 1)

    account_with_recent_traffic = FactoryBot.create(:buyer_account)
    FactoryBot.create(:cinstance, user_account: account_with_recent_traffic, first_daily_traffic_at: (inactive_since_days - 1.day).ago)

    assert_raise(ArgumentError) { Account.without_traffic_since.pluck(:id) }
    results = Account.without_traffic_since(inactive_since_days.ago).pluck(:id)
    assert_includes results, account_without_traffic.id
    assert_includes results, account_with_old_traffic.id
    assert_not_includes results, account_with_recent_traffic.id
  end

  class CallbacksTest < ActiveSupport::TestCase

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
        freeze_time do
          account.public_send(transition)
          assert_equal Time.zone.now.to_s, account.reload.state_changed_at.to_s
        end
      end
    end

  end
end
