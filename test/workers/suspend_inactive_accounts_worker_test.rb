# frozen_string_literal: true

require 'test_helper'

class SuspendInactiveAccountsWorkerTest < ActiveSupport::TestCase
  setup do
    account_inactivity = 50
    config = {'account_suspension' => 30, 'account_inactivity' => account_inactivity, 'contract_unpaid_time' => 70}
    ThreeScale.config.features.stubs(:account_deletion).returns(config)

    @accounts = {to_suspend: [], not_to_suspend: []}

    old_tenant_with_old_traffic = FactoryBot.create(:simple_provider)
    old_tenant_with_old_traffic.update_attribute(:created_at, (account_inactivity + 1).days.ago)
    FactoryBot.create(:cinstance, user_account: old_tenant_with_old_traffic, first_daily_traffic_at: (account_inactivity + 1).days.ago)
    @accounts[:to_suspend] << old_tenant_with_old_traffic

    old_buyer_with_old_traffic = FactoryBot.create(:simple_buyer)
    old_buyer_with_old_traffic.update_attribute(:created_at, (account_inactivity + 1).days.ago)
    FactoryBot.create(:cinstance, user_account: old_buyer_with_old_traffic, first_daily_traffic_at: (account_inactivity + 1).days.ago)
    @accounts[:not_to_suspend] << old_buyer_with_old_traffic

    recent_tenant_without_traffic = FactoryBot.create(:simple_provider)
    recent_tenant_without_traffic.update_attribute(:created_at, (account_inactivity - 1).days.ago)
    @accounts[:not_to_suspend] << recent_tenant_without_traffic

    recent_tenant_with_recent_traffic = FactoryBot.create(:simple_provider)
    recent_tenant_with_recent_traffic.update_attribute(:created_at, (account_inactivity + 1).days.ago)
    FactoryBot.create(:cinstance, user_account: recent_tenant_with_recent_traffic, first_daily_traffic_at:  (account_inactivity - 1).days.ago)
    @accounts[:not_to_suspend] << recent_tenant_with_recent_traffic

    old_tenant_without_traffic = FactoryBot.create(:simple_provider)
    old_tenant_without_traffic.update_attribute(:created_at, (account_inactivity + 1).days.ago)
    @accounts[:to_suspend] << old_tenant_without_traffic

    master_account.update_attribute(:created_at, (account_inactivity + 1).days.ago)
    @accounts[:not_to_suspend] << master_account
  end

  test 'perform suspends inactive accounts' do
    SuspendInactiveAccountsWorker.new.perform
    @accounts[:to_suspend].each     { |account| assert account.reload.suspended? }
    @accounts[:not_to_suspend].each { |account| refute account.reload.suspended? }
  end

  test 'it does not perform for already suspended or deleted accounts' do
    old_time = 5.years.ago
    already_suspended = FactoryBot.create(:simple_provider, state: 'suspended', state_changed_at: old_time)
    already_suspended.update_attribute(:created_at, 1.day.ago)
    already_deleted = FactoryBot.create(:simple_provider, state: 'scheduled_for_deletion', state_changed_at: old_time)
    already_deleted.update_attribute(:created_at, 1.day.ago)

    SuspendInactiveAccountsWorker.new.perform

    assert_equal old_time.to_date, already_suspended.reload.state_changed_at.to_date
    assert_equal old_time.to_date, already_deleted.reload.state_changed_at.to_date
    assert already_deleted.scheduled_for_deletion?
  end

  test 'it does not perform unless it has the valid configuration' do
    AccountDeletionConfig.stubs(valid?: false)
    SuspendInactiveAccountsWorker.new.perform
    (@accounts[:to_suspend] + @accounts[:not_to_suspend]).each { |account| refute account.reload.suspended? }
  end

  test 'it does not perform for paid accounts' do
    Account.stubs(free: Account.none)
    SuspendInactiveAccountsWorker.new.perform
    (@accounts[:to_suspend] + @accounts[:not_to_suspend]).each { |account| refute account.reload.suspended? }
  end

  test 'it does not perform for enterprise accounts' do
    Account.stubs(not_enterprise: Account.none)
    SuspendInactiveAccountsWorker.new.perform
    (@accounts[:to_suspend] + @accounts[:not_to_suspend]).each { |account| refute account.reload.suspended? }
  end
end
