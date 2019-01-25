# frozen_string_literal: true

require 'test_helper'

class StaleAccountWorkerTest < ActiveSupport::TestCase
  setup do
    @accounts = {to_delete: [], not_to_delete: []}

    tenant_suspended_long_ago = FactoryBot.create(:simple_provider, state: 'suspended')
    tenant_suspended_long_ago.update_attribute(:state_changed_at, Account::States::MAX_PERIOD_OF_SUSPENSION.ago)
    @accounts[:to_delete] << tenant_suspended_long_ago

    tenant_suspended_recently = FactoryBot.create(:simple_provider, state: 'suspended')
    tenant_suspended_recently.update_attribute(:state_changed_at, (Account::States::MAX_PERIOD_OF_SUSPENSION - 1.day).ago)
    @accounts[:not_to_delete] << tenant_suspended_recently

    buyer_suspended_long_ago = FactoryBot.create(:simple_buyer, state: 'suspended')
    buyer_suspended_long_ago.update_attribute(:state_changed_at, Account::States::MAX_PERIOD_OF_SUSPENSION.ago)
    @accounts[:not_to_delete] << buyer_suspended_long_ago

    tenant_approved_long_ago = FactoryBot.create(:simple_provider, state: 'approved')
    tenant_approved_long_ago.update_attribute(:state_changed_at, Account::States::MAX_PERIOD_OF_SUSPENSION.ago)
    @accounts[:not_to_delete] << tenant_approved_long_ago
  end

  test 'perform schedules for deletion suspended accounts' do
    StaleAccountWorker.new.perform
    @accounts[:to_delete].each     { |account| assert account.reload.scheduled_for_deletion? }
    @accounts[:not_to_delete].each { |account| refute account.reload.scheduled_for_deletion? }
  end

  test 'it does not perform for on-prem' do
    ThreeScale.config.stubs(onpremises: true)
    StaleAccountWorker.new.perform
    (@accounts[:to_delete] + @accounts[:not_to_delete]).each { |account| refute account.reload.scheduled_for_deletion? }
  end
end
