# frozen_string_literal: true

require 'test_helper'

class Signup::MasterDomainsBuilderTest < ActiveSupport::TestCase
  test 'org_name is base for the subdomain' do
    new_domains = generate_domains(org_name: 'Master Account')
    assert_equal 'master-account', new_domains.subdomain
  end

  test 'current_subdomain is kept if present' do
    new_domains = generate_domains(org_name: 'Master Account', current_subdomain: 'master')
    assert_equal 'master', new_domains.subdomain
  end

  test 'generates equal subdomain and self subdomain' do
    new_domains = generate_domains(org_name: 'Master Account')
    assert_equal new_domains.subdomain, new_domains.self_subdomain
  end

  private

  def generate_domains(org_name:, current_subdomain: nil)
    provider = FactoryGirl.build(:simple_provider)
    domains_builder_params = { org_name: org_name, current_subdomain: current_subdomain, invalid_subdomain_condition: provider.method(:subdomain_exists?) }
    Signup::MasterDomainsBuilder.new(**domains_builder_params).generate
  end
end
