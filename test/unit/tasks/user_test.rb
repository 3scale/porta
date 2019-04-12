# frozen_string_literal: true

require 'test_helper'

class Tasks::UserTest < ActiveSupport::TestCase
  test 'update_all_first_admin_id' do
    providers = FactoryBot.create_list(:simple_provider, 3, provider_account: master_account)
    providers.each do |provider|
      FactoryBot.create(:member, account: provider)
      FactoryBot.create(:admin, username: '3scaleadmin', account: provider)
      FactoryBot.create_list(:admin, 2, account: provider)
    end
    FactoryBot.create(:admin, account: FactoryBot.create(:simple_buyer, provider_account: providers.first))

    execute_rake_task 'user.rake', 'user:update_all_first_admin_id'

    Account.find_each { |account| assert_equal account.first_admin&.id, account.first_admin_id }
  end

  test 'obfuscate_buyer_private_data_and_repair_tenant_id' do
    tenants = FactoryBot.create_list(:simple_provider, 3, provider_account: master_account)
    devs = tenants.map { |tenant| FactoryBot.create(:buyer_account, provider_account: tenant, tenant_id: nil) }
    users = devs.map { |dev_account| FactoryBot.create(:admin, account: dev_account, username: 'private', email: 'private@example.com', tenant_id: nil) }

    execute_rake_task 'user.rake', 'user:obfuscate_buyer_private_data_and_repair_tenant_id', users.map(&:id)

    users.each do |user|
      user.reload
      assert_equal "someone#{user.id}", user.username
      assert_equal "someone#{user.id}@example.com", user.email
      assert_equal user.account.provider_account.id, user.tenant_id
      assert_equal user.tenant_id, user.account.tenant_id
    end
  end
end
