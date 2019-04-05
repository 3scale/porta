# frozen_string_literal: true

require 'test_helper'

class Tasks::Multitenant::TenantsTest < ActiveSupport::TestCase
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
  end
end
