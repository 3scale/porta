require 'test_helper'

class Account::StatesTest < ActiveSupport::TestCase

  def test_events_when_state_changed
    account = FactoryGirl.create(:simple_account)

    Accounts::AccountStateChangedEvent.expects(:create)
                                      .with(account, 'approved').once

    PublishEnabledChangedEventForProviderApplicationsWorker
        .expects(:perform_later)
        .with(account, 'approved').once

    account.make_pending!
  end

  def test_events_when_state_not_changed
    account = FactoryGirl.create(:simple_account)
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
    account = Factory(:pending_account)

    assert_change :of   => lambda { account.state },
                  :from => "pending",
                  :to   => "approved" do
      account.approve!
    end
  end

  test 'approve! transitions from rejected to approved' do
    account = Factory(:pending_account)
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
    account = Factory(:buyer_account_with_provider)
    account.make_pending!

    AccountMailer.any_instance.expects(:confirmed)
    account.send(:_run_after_commit_queue)
  end

  test 'sends notification email when account is rejected' do
    account = Factory(:buyer_account_with_provider)
    account.reject!

    AccountMailer.any_instance.expects(:rejected)
    account.send(:_run_after_commit_queue)
  end

  test 'sends notification email when buyer account is approved' do
    account = Factory(:buyer_account_with_provider)

    account.update_attribute(:state, 'pending')
    account.buy! Factory(:account_plan, :approval_required => true)
    account.reload
    account.approve!

    AccountMailer.any_instance.expects(:approved)
    account.send(:_run_after_commit_queue)
  end

  test 'does not send notification email when non buyer account is approved' do
    AccountMailer.any_instance.expects(:approved).never

    account = Factory(:pending_account)
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
    account = FactoryGirl.build_stubbed(:simple_provider, master: true)
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
    accounts = FactoryGirl.create_list(:simple_account, 3)

    account_deleted_recently = accounts[0]
    account_deleted_recently.schedule_for_deletion!
    account_deleted_recently.update_attribute(:deleted_at, (Account::States::PERIOD_BEFORE_DELETION.ago + 1.day))

    account_deleted_long_ago = accounts[1]
    account_deleted_long_ago.schedule_for_deletion!
    account_deleted_long_ago.update_attribute(:deleted_at, Account::States::PERIOD_BEFORE_DELETION.ago)

    account_not_deleted = accounts[2]

    results = Account.deleted_since.pluck(:id)
    assert_not_includes results, account_deleted_recently.id
    assert_includes     results, account_deleted_long_ago.id
    assert_not_includes results, account_not_deleted.id
  end

  test '.deletion_date' do
    account = FactoryGirl.create(:simple_account)
    account.schedule_for_deletion!
    assert_equal Account::States::PERIOD_BEFORE_DELETION.from_now.to_date, account.deletion_date.to_date
  end

  class CallbacksTest < ActiveSupport::TestCase
    disable_transactional_fixtures!

    def test_suspend
      account = FactoryGirl.create(:provider_account)

      ThreeScale::Analytics.expects(:track).with(account.first_admin, 'Account Suspended')
      ReverseProviderKeyWorker.expects(:enqueue).with(account)

      assert account.suspend!
    end

    def test_resume_from_suspended
      account = FactoryGirl.create(:provider_account)
      account.update_columns(state: 'suspended')

      ThreeScale::Analytics.expects(:track).with(account.first_admin, 'Account Resumed')
      ReverseProviderKeyWorker.expects(:enqueue).with(account)

      assert account.resume!
    end

    def test_resume_from_scheduled_for_deletion
      account = FactoryGirl.create(:simple_provider)
      account.schedule_for_deletion!

      BackendProviderSyncWorker.expects(:enqueue).with(account.id)

      account.resume!
      account.reload
      assert_nil account.deleted_at
      assert_nil account.state_changed_at
    end

    def test_schedule_for_deletion
      account = FactoryGirl.create(:simple_provider)
      refute account.scheduled_for_deletion?

      BackendProviderSyncWorker.expects(:enqueue).with(account.id)

      Timecop.freeze do
        account.schedule_for_deletion!
        account.reload
        assert_equal Time.zone.now.to_s, account.deleted_at.to_s
        assert_equal Time.zone.now.to_s, account.state_changed_at.to_s
      end
    end
  end
end
