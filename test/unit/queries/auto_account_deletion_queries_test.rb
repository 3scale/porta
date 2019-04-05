# frozen_string_literal: true

require 'test_helper'

class AutoAccountDeletionQueriesTest < ActiveSupport::TestCase
  def setup
    @account_suspension   = 30
    @account_inactivity   = 50
    @contract_unpaid_time = 70
    config = {'account_suspension' => account_suspension, 'account_inactivity' => account_inactivity, 'contract_unpaid_time' => contract_unpaid_time, disabled_for_app_plans: ['enterprise']}
    Features::AccountDeletionConfig.configure(config)
    Features::AccountDeletionConfig.stubs(enabled?: true)
  end

  attr_reader :account_suspension, :account_inactivity, :contract_unpaid_time

  class AutomatedSuspensionFeatureTest < AutoAccountDeletionQueriesTest
    def setup
      super

      @accounts = {to_suspend: [], not_to_suspend: []}

      old_tenant_with_old_traffic = FactoryBot.create(:simple_provider)
      old_tenant_with_old_traffic.update_attribute(:created_at, (account_inactivity + 1).days.ago)
      FactoryBot.create(:cinstance, user_account: old_tenant_with_old_traffic, first_daily_traffic_at: (account_inactivity + 1).days.ago)
      @accounts[:to_suspend] << old_tenant_with_old_traffic.id

      old_tenant_with_old_traffic_but_enterprise = FactoryBot.create(:simple_provider)
      old_tenant_with_old_traffic_but_enterprise.update_attribute(:created_at, (account_inactivity + 1).days.ago)
      plan = FactoryBot.create(:application_plan, system_name: 'enterprise', issuer: master_account.default_service)
      FactoryBot.create(:cinstance, user_account: old_tenant_with_old_traffic_but_enterprise, first_daily_traffic_at: (account_inactivity + 1).days.ago, plan: plan)
      @accounts[:not_to_suspend] << old_tenant_with_old_traffic_but_enterprise.id

      old_tenant_with_old_traffic_but_paid = FactoryBot.create(:simple_provider)
      old_tenant_with_old_traffic_but_paid.update_attribute(:created_at, (account_inactivity + 1).days.ago)
      FactoryBot.create(:cinstance, user_account: old_tenant_with_old_traffic_but_paid, first_daily_traffic_at: (account_inactivity + 1).days.ago, paid_until: (contract_unpaid_time - 1).days.ago)
      @accounts[:not_to_suspend] << old_tenant_with_old_traffic_but_paid.id

      old_buyer_with_old_traffic = FactoryBot.create(:simple_buyer)
      old_buyer_with_old_traffic.update_attribute(:created_at, (account_inactivity + 1).days.ago)
      FactoryBot.create(:cinstance, user_account: old_buyer_with_old_traffic, first_daily_traffic_at: (account_inactivity + 1).days.ago)
      @accounts[:not_to_suspend] << old_buyer_with_old_traffic.id

      recent_tenant_without_traffic = FactoryBot.create(:simple_provider)
      recent_tenant_without_traffic.update_attribute(:created_at, (account_inactivity - 1).days.ago)
      @accounts[:not_to_suspend] << recent_tenant_without_traffic.id

      recent_tenant_with_recent_traffic = FactoryBot.create(:simple_provider)
      recent_tenant_with_recent_traffic.update_attribute(:created_at, (account_inactivity + 1).days.ago)
      FactoryBot.create(:cinstance, user_account: recent_tenant_with_recent_traffic, first_daily_traffic_at:  (account_inactivity - 1).days.ago)
      @accounts[:not_to_suspend] << recent_tenant_with_recent_traffic.id

      old_tenant_without_traffic = FactoryBot.create(:simple_provider)
      old_tenant_without_traffic.update_attribute(:created_at, (account_inactivity + 1).days.ago)
      @accounts[:to_suspend] << old_tenant_without_traffic.id

      master_account.update_attribute(:created_at, (account_inactivity + 1).days.ago)
      @accounts[:not_to_suspend] << master_account.id
    end

    test 'it finds the right accounts' do
      result_ids = AutoAccountDeletionQueries.should_be_suspended.pluck(:id)
      @accounts[:to_suspend].each     { |account_id| assert_includes(result_ids, account_id) }
      @accounts[:not_to_suspend].each { |account_id| assert_not_includes(result_ids, account_id) }
    end

    test 'it does not perform for already suspended or deleted accounts' do
      old_time = 5.years.ago
      already_suspended = FactoryBot.create(:simple_provider, state: 'suspended', state_changed_at: old_time)
      already_suspended.update_attribute(:created_at, 1.day.ago)
      already_deleted = FactoryBot.create(:simple_provider, state: 'scheduled_for_deletion', state_changed_at: old_time)
      already_deleted.update_attribute(:created_at, 1.day.ago)

      result_ids = AutoAccountDeletionQueries.should_be_suspended.pluck(:id)

      assert_not_includes result_ids, already_suspended.id
      assert_not_includes result_ids, already_deleted.id
    end

    test 'it returns empty if the feature is disabled' do
      Features::AccountDeletionConfig.stubs(enabled?: false)
      assert_empty AutoAccountDeletionQueries.should_be_suspended.pluck(:id)
    end
  end

  class AutomatedScheduleForDeletionFeatureTest < AutoAccountDeletionQueriesTest
    def setup
      super

      @accounts = {to_delete: [], not_to_delete: []}

      tenant_suspended_long_ago = FactoryBot.create(:simple_provider, state: 'suspended')
      tenant_suspended_long_ago.update_attribute(:state_changed_at, account_suspension.days.ago)
      @accounts[:to_delete] << tenant_suspended_long_ago.id

      tenant_suspended_long_ago_but_enterprise = FactoryBot.create(:simple_provider, state: 'suspended')
      tenant_suspended_long_ago_but_enterprise.update_attribute(:state_changed_at, account_suspension.days.ago)
      plan = FactoryBot.create(:application_plan, system_name: 'enterprise', issuer: master_account.default_service)
      FactoryBot.create(:cinstance, user_account: tenant_suspended_long_ago_but_enterprise, plan: plan)
      @accounts[:not_to_delete] << tenant_suspended_long_ago_but_enterprise.id

      tenant_suspended_long_ago_but_paid = FactoryBot.create(:simple_provider, state: 'suspended')
      tenant_suspended_long_ago_but_paid.update_attribute(:state_changed_at, account_suspension.days.ago)
      FactoryBot.create(:cinstance, user_account: tenant_suspended_long_ago_but_paid, paid_until: (contract_unpaid_time - 1).days.ago)
      @accounts[:not_to_delete] << tenant_suspended_long_ago_but_paid.id

      tenant_suspended_recently = FactoryBot.create(:simple_provider, state: 'suspended')
      tenant_suspended_recently.update_attribute(:state_changed_at, (account_suspension - 1).days.ago)
      @accounts[:not_to_delete] << tenant_suspended_recently.id

      buyer_suspended_long_ago = FactoryBot.create(:simple_buyer, state: 'suspended')
      buyer_suspended_long_ago.update_attribute(:state_changed_at, account_suspension.days.ago)
      @accounts[:not_to_delete] << buyer_suspended_long_ago.id

      tenant_approved_long_ago = FactoryBot.create(:simple_provider, state: 'approved')
      tenant_approved_long_ago.update_attribute(:state_changed_at, account_suspension.days.ago)
      @accounts[:not_to_delete] << tenant_approved_long_ago.id

      @accounts[:not_to_delete] << master_account.id
    end

    test 'it finds the right accounts' do
      result_ids = AutoAccountDeletionQueries.should_be_scheduled_for_deletion.pluck(:id)
      @accounts[:to_delete].each     { |account_id| assert_includes(result_ids, account_id) }
      @accounts[:not_to_delete].each { |account_id| assert_not_includes(result_ids, account_id) }
    end

    test 'it returns empty if the feature is disabled' do
      Features::AccountDeletionConfig.stubs(enabled?: false)
      assert_empty AutoAccountDeletionQueries.should_be_scheduled_for_deletion.pluck(:id)
    end
  end
end
