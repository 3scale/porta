# frozen_string_literal: true

require 'test_helper'

class StaleAccountWorkerTest < ActiveSupport::TestCase
  setup do
    account_suspension = 30
    config = {'account_suspension' => account_suspension, 'account_inactivity' => 50, 'contract_unpaid_time' => 70}
    ThreeScale.config.stubs(:max_allowed_days).returns(config)

    @accounts = {to_delete: [], not_to_delete: []}

    tenant_suspended_long_ago = FactoryBot.create(:simple_provider, state: 'suspended')
    tenant_suspended_long_ago.update_attribute(:state_changed_at, account_suspension.days.ago)
    @accounts[:to_delete] << tenant_suspended_long_ago

    tenant_suspended_recently = FactoryBot.create(:simple_provider, state: 'suspended')
    tenant_suspended_recently.update_attribute(:state_changed_at, (account_suspension - 1).days.ago)
    @accounts[:not_to_delete] << tenant_suspended_recently

    buyer_suspended_long_ago = FactoryBot.create(:simple_buyer, state: 'suspended')
    buyer_suspended_long_ago.update_attribute(:state_changed_at, account_suspension.days.ago)
    @accounts[:not_to_delete] << buyer_suspended_long_ago

    tenant_approved_long_ago = FactoryBot.create(:simple_provider, state: 'approved')
    tenant_approved_long_ago.update_attribute(:state_changed_at, account_suspension.days.ago)
    @accounts[:not_to_delete] << tenant_approved_long_ago
  end

  test 'perform schedules for deletion suspended accounts' do
    StaleAccountWorker.new.perform
    @accounts[:to_delete].each     { |account| assert account.reload.scheduled_for_deletion? }
    @accounts[:not_to_delete].each { |account| refute account.reload.scheduled_for_deletion? }
  end

  test 'it does not perform for unless it has the valid configuration' do
    AccountSuspensionConfig.stubs(valid?: false)
    StaleAccountWorker.new.perform
    (@accounts[:to_delete] + @accounts[:not_to_delete]).each { |account| refute account.reload.scheduled_for_deletion? }
  end

  test 'it does not perform for paid accounts' do
    Account.stubs(free: Account.none)
    StaleAccountWorker.new.perform
    (@accounts[:to_delete] + @accounts[:not_to_delete]).each { |account| refute account.reload.scheduled_for_deletion? }
  end

  test 'it does not perform for enterprise accounts' do
    Account.stubs(not_enterprise: Account.none)
    StaleAccountWorker.new.perform
    (@accounts[:to_delete] + @accounts[:not_to_delete]).each { |account| refute account.reload.scheduled_for_deletion? }
  end
end
