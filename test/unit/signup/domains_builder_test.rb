# frozen_string_literal: true

require 'test_helper'

module Signup
  class DomainsBuilderTest < ActiveSupport::TestCase
    test '.generate_subdomain normalizes the input' do
      assert_equal 'foo-bar', generate_subdomain(org_name: 'Foo Bar')
    end

    test 'generate returns unique subdomain' do
      FactoryBot.create(:simple_account, :provider_account => master_account, :domain => "foo.#{master_account.superdomain}")
      assert_equal 'foo-2', generate_subdomain(org_name: 'Foo')

      FactoryBot.create(:simple_account, :provider_account => master_account, :domain => "foo-2.#{master_account.superdomain}")
      assert_equal 'foo-3', generate_subdomain(org_name: 'Foo')

      FactoryBot.create(:simple_account, :provider_account => master_account, :domain => "foo-42.#{master_account.superdomain}")
      assert_equal 'foo-3', generate_subdomain(org_name: 'Foo')
    end

    test 'generate raises ArgumentError when org_name and current_subdomain are blank' do
      assert_raise(ArgumentError) { generate_subdomain(org_name: '', current_subdomain: '') }
    end

    private

    def generate_subdomain(org_name:, current_subdomain: nil)
      provider = FactoryBot.build(:simple_provider)
      domains_builder_params = { org_name: org_name, current_subdomain: current_subdomain, invalid_subdomain_condition: provider.method(:subdomain_exists?) }
      Signup::DomainsBuilder.new(domains_builder_params).generate.subdomain
    end
  end
end
