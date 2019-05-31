# frozen_string_literal: true

require 'test_helper'

class Tasks::Multitenant::TenantsTest < ActiveSupport::TestCase
  class UpdateTenantIdTest < ActiveSupport::TestCase
    test 'fix_corrupted_tenant_id_accounts fixes buyers with tenant_id = provider_account_id' do
      provider = FactoryBot.create(:simple_provider)
      buyers_to_update = FactoryBot.create_list(:simple_buyer, 2, provider_account: provider, tenant_id: nil)
      buyer_not_to_update = FactoryBot.create(:simple_buyer, provider_account: provider, tenant_id: nil)
      [buyers_to_update, buyer_not_to_update].flatten.each { |account| account.update_column(:tenant_id, -1) }

      Rails.application.expects(:simple_try_config_for).with('corrupted_accounts').returns(YAML.load(buyers_to_update.map(&:id).to_yaml))

      ENV['FILE'] = 'corrupted_accounts'
      execute_rake_task 'multitenant/tenants.rake', 'multitenant:tenants:fix_corrupted_tenant_id_accounts', '1', '1'

      buyers_to_update.each { |buyer| assert_equal provider.id, buyer.reload.tenant_id }
      assert_equal -1, buyer_not_to_update.reload.tenant_id
    end

    test 'fix_corrupted_tenant_id_accounts fixes providers with tenant_id = id' do
      providers_to_update = FactoryBot.create_list(:simple_provider, 2, provider_account: master_account)
      provider_not_to_update = FactoryBot.create(:simple_provider, provider_account: master_account)
      [providers_to_update, provider_not_to_update].flatten.each { |account| account.update_column(:tenant_id, -1) }

      Rails.application.expects(:simple_try_config_for).with('corrupted_accounts').returns(YAML.load(providers_to_update.map(&:id).to_yaml))

      ENV['FILE'] = 'corrupted_accounts'
      execute_rake_task 'multitenant/tenants.rake', 'multitenant:tenants:fix_corrupted_tenant_id_accounts', '1', '1'

      providers_to_update.each { |provider| assert_equal provider.id, provider.reload.tenant_id }
      assert_equal -1, provider_not_to_update.reload.tenant_id
    end

    test 'fix_corrupted_tenant_id_for_table_associated_to_account for a date range or nil' do
      account = FactoryBot.create(:simple_provider)
      users = FactoryBot.create_list(:simple_user, 4, account: account)
      account.update_column(:tenant_id, account.id)
      User.where(id: users[0..1].map(&:id)).update_all(tenant_id: nil)
      User.where(id: users[2..3].map(&:id)).update_all(tenant_id: -1, created_at: Time.strptime('01/24/2019 11:00 UTC', '%m/%d/%Y %H:%M %Z'))

      execute_rake_task 'multitenant/tenants.rake', 'multitenant:tenants:fix_corrupted_tenant_id_for_table_associated_to_account', 'User', '01/24/2019 08:00 UTC', '01/24/2019 16:30 UTC', '3', '1'

      users.each { |user| assert_equal account.reload.tenant_id, user.reload.tenant_id }
    end

    test 'fix_corrupted_tenant_id_for_table_associated_to_user for a date range or nil' do
      user = FactoryBot.create(:simple_user, account: FactoryBot.create(:simple_provider))
      sso_authorizations = FactoryBot.create_list(:sso_authorization, 4, user: user)
      user.update_column(:tenant_id, user.account.id)
      SSOAuthorization.where(id: sso_authorizations[0..1].map(&:id)).update_all(tenant_id: nil)
      SSOAuthorization.where(id: sso_authorizations[2..3].map(&:id)).update_all(tenant_id: -1, created_at: Time.strptime('01/24/2019 11:00 UTC', '%m/%d/%Y %H:%M %Z'))

      execute_rake_task 'multitenant/tenants.rake', 'multitenant:tenants:fix_corrupted_tenant_id_for_table_associated_to_user', 'SSOAuthorization', '01/24/2019 08:00 UTC', '01/24/2019 16:30 UTC', '3', '1'

      sso_authorizations.each { |sso_authorization| assert_equal user.reload.tenant_id, sso_authorization.reload.tenant_id }
    end

    test 'fix_empty_tenant_id_access_tokens' do
      user = FactoryBot.create(:simple_user, account: FactoryBot.create(:simple_provider))
      access_tokens = FactoryBot.create_list(:access_token, 3, owner: user)
      user.update_column(:tenant_id, user.account.id)
      AccessToken.where(id: access_tokens.map(&:id)).update_all(tenant_id: nil)

      execute_rake_task 'multitenant/tenants.rake', 'multitenant:tenants:fix_empty_tenant_id_access_tokens', '3', '1'

      access_tokens.each { |access_token| assert_equal user.reload.tenant_id, access_token.reload.tenant_id }
    end

    test 'restore_existing_tenant_id_alerts' do
      account = FactoryBot.create(:simple_provider)
      alerts_empty = FactoryBot.create_list(:limit_alert, 2, account: account)
      alerts_with_tenant_id = FactoryBot.create_list(:limit_alert, 2, account: account)
      account.update_column(:tenant_id, account.id)
      Alert.where(id: alerts_empty.map(&:id)).update_all(tenant_id: nil)
      Alert.where(id: alerts_with_tenant_id.map(&:id)).update_all(tenant_id: -1)

      execute_rake_task 'multitenant/tenants.rake', 'multitenant:tenants:restore_existing_tenant_id_alerts', '3', '1'

      alerts_with_tenant_id.each { |alert| assert_equal account.reload.tenant_id, alert.reload.tenant_id }
      alerts_empty.each { |alert| assert_nil alert.reload.tenant_id }
    end

    test 'restore_empty_tenant_id_alerts' do
      account = FactoryBot.create(:simple_provider)
      alerts_empty = FactoryBot.create_list(:limit_alert, 2, account: account)
      alerts_with_tenant_id = FactoryBot.create_list(:limit_alert, 2, account: account)
      account.update_column(:tenant_id, account.id)
      Alert.where(id: alerts_empty.map(&:id)).update_all(tenant_id: nil)
      Alert.where(id: alerts_with_tenant_id.map(&:id)).update_all(tenant_id: -1)

      execute_rake_task 'multitenant/tenants.rake', 'multitenant:tenants:restore_empty_tenant_id_alerts', '3', '1'

      alerts_empty.each { |alert| assert_equal account.reload.tenant_id, alert.reload.tenant_id }
      alerts_with_tenant_id.each { |alert| assert_equal -1, alert.reload.tenant_id }
    end
  end

  class ExportOrgNamesYamlTest < Tasks::Multitenant::TenantsTest
    setup do
      FactoryBot.create_list(:simple_provider, 5)
      FactoryBot.create_list(:simple_buyer, 2)
    end

    teardown do
      file_name = 'tenants_organization_names.yml'
      File.delete(file_name) if File.exist?(file_name)
    end

    test 'export_org_names_to_yaml' do
      execute_rake_task 'multitenant/tenants.rake', 'multitenant:tenants:export_org_names_to_yaml'

      assert_equal Account.providers.order(:id).pluck(:org_name), YAML.load_file('tenants_organization_names.yml')
    end
  end

  class SuspendEnterpriseScheduledForDeletionTest < Tasks::Multitenant::TenantsTest
    setup do
      config = {'account_suspension' => 2, 'account_inactivity' => 3, 'contract_unpaid_time' => 4, disabled_for_app_plans: ['enterprise']}
      Features::AccountDeletionConfig.configure(config)
      Features::AccountDeletionConfig.stubs(enabled?: true)

      enterprise_plan = FactoryBot.create(:application_plan, system_name: 'enterprise', issuer: master_account.default_service)
      pro_plan = FactoryBot.create(:application_plan, system_name: 'pro', issuer: master_account.default_service)

      @tenant_with_enterprise = FactoryBot.create(:simple_provider, state: 'scheduled_for_deletion')
      FactoryBot.create(:cinstance, user_account: @tenant_with_enterprise, plan: enterprise_plan)

      @tenant_with_pro = FactoryBot.create(:simple_provider, state: 'scheduled_for_deletion')
      FactoryBot.create(:cinstance, user_account: @tenant_with_pro, plan: pro_plan)

      @tenant_with_enterprise_and_pro = FactoryBot.create(:simple_provider, state: 'scheduled_for_deletion')
      FactoryBot.create(:cinstance, user_account: @tenant_with_enterprise_and_pro, plan: enterprise_plan)
      FactoryBot.create(:cinstance, user_account: @tenant_with_enterprise_and_pro, plan: pro_plan)

      @tenant_without_any_cinstance = FactoryBot.create(:simple_provider, state: 'scheduled_for_deletion')

      @developer_with_enterprise = FactoryBot.create(:simple_buyer, state: 'scheduled_for_deletion')
      cinstance = FactoryBot.create(:cinstance, user_account: @developer_with_enterprise)
      cinstance.plan.update_column(:system_name, 'enterprise')
    end

    test 'it suspends only the tenants with a enterprise cinstance' do
      execute_rake_task 'multitenant/tenants.rake', 'multitenant:tenants:suspend_forbidden_plans_scheduled_for_deletion'

      assert @tenant_with_enterprise.reload.suspended?
      assert @tenant_with_enterprise_and_pro.reload.suspended?
      assert @tenant_with_pro.reload.scheduled_for_deletion?
      assert @tenant_without_any_cinstance.reload.scheduled_for_deletion?
      assert @developer_with_enterprise.reload.scheduled_for_deletion?
    end

    test 'it does nothing with the config is disabled' do
      Features::AccountDeletionConfig.stubs(enabled?: false)
      assert @tenant_with_enterprise.reload.scheduled_for_deletion?
      assert @tenant_with_enterprise_and_pro.reload.scheduled_for_deletion?
      assert @tenant_with_pro.reload.scheduled_for_deletion?
      assert @tenant_without_any_cinstance.reload.scheduled_for_deletion?
      assert @developer_with_enterprise.reload.scheduled_for_deletion?
    end
  end
end
