require 'test_helper'

class Tasks::Multitenant::TenantsTest < ActiveSupport::TestCase
  setup do
    FactoryBot.create_list(:simple_provider, 5)
    FactoryBot.create_list(:simple_buyer, 2)
  end

  teardown do
    file_name = 'tenants_organization_names.yml'
    File.delete(file_name) if File.exists?(file_name)
  end

  test 'export_org_names_to_yaml' do
    execute_rake_task 'multitenant/tenants.rake', 'multitenant:tenants:export_org_names_to_yaml'

    assert_equal Account.providers.pluck(:org_name), YAML.load_file('tenants_organization_names.yml')
  end
end
