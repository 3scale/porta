# frozen_string_literal: true

require 'test_helper'

class SuspendInactiveAccountsWorkerTest < ActiveSupport::TestCase
  setup do
    @accounts = {to_suspend: [], not_to_suspend: []}

    old_tenant_with_old_traffic = FactoryBot.create(:simple_provider)
    old_tenant_with_old_traffic.update_attribute(:created_at, Account::States::MAX_PERIOD_OF_INACTIVITY.ago)
    FactoryBot.create(:cinstance, user_account: old_tenant_with_old_traffic, first_daily_traffic_at: Account::States::MAX_PERIOD_OF_INACTIVITY.ago)
    @accounts[:to_suspend] << old_tenant_with_old_traffic

    old_buyer_with_old_traffic = FactoryBot.create(:simple_buyer)
    old_buyer_with_old_traffic.update_attribute(:created_at, Account::States::MAX_PERIOD_OF_INACTIVITY.ago)
    FactoryBot.create(:cinstance, user_account: old_buyer_with_old_traffic, first_daily_traffic_at: Account::States::MAX_PERIOD_OF_INACTIVITY.ago)
    @accounts[:not_to_suspend] << old_buyer_with_old_traffic

    recent_tenant_without_traffic = FactoryBot.create(:simple_provider)
    recent_tenant_without_traffic.update_attribute(:created_at, (Account::States::MAX_PERIOD_OF_INACTIVITY - 1.day).ago)
    @accounts[:not_to_suspend] << recent_tenant_without_traffic

    recent_tenant_with_recent_traffic = FactoryBot.create(:simple_provider)
    recent_tenant_with_recent_traffic.update_attribute(:created_at, Account::States::MAX_PERIOD_OF_INACTIVITY.ago)
    FactoryBot.create(:cinstance, user_account: recent_tenant_with_recent_traffic, first_daily_traffic_at: (Account::States::MAX_PERIOD_OF_INACTIVITY - 1.day).ago)
    @accounts[:not_to_suspend] << recent_tenant_with_recent_traffic

    old_tenant_without_traffic = FactoryBot.create(:simple_provider)
    old_tenant_without_traffic.update_attribute(:created_at, Account::States::MAX_PERIOD_OF_INACTIVITY.ago)
    @accounts[:to_suspend] << old_tenant_without_traffic

    master_account.update_attribute(:created_at, Account::States::MAX_PERIOD_OF_INACTIVITY.ago)
    @accounts[:not_to_suspend] << master_account
  end

  test 'perform suspends inactive accounts' do
    SuspendInactiveAccountsWorker.new.perform
    @accounts[:to_suspend].each     { |account| assert account.reload.suspended? }
    @accounts[:not_to_suspend].each { |account| refute account.reload.suspended? }
  end

  test 'it does not perform for on-prem' do
    ThreeScale.config.stubs(onpremises: true)
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
