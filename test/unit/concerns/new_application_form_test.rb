# frozen_string_literal: true

require 'test_helper'

module Concerns
  class NewApplicationFormTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper
    include NewApplicationForm

    def setup
      @provider = FactoryBot.create(:simple_provider)
      @user = FactoryBot.create(:simple_user, account: @provider)
    end

    def service_plans_management_visible?
      true
    end

    attr_reader :provider, :pagination_params, :user

    test "new_application_form_base_data" do
      form_data = new_application_form_base_data(provider)

      expected_keys = %i[create-application-plan-path create-service-plan-path service-subscriptions-path service-plans-allowed defined-fields]
      unexpected_keys = %i[most-recently-updated-products products-count buyer errors product most-recently-created-buyers buyers-count]

      assert_same_elements expected_keys, form_data.keys
      unexpected_keys.each { |key| assert_does_not_contain form_data.keys, key }
    end

    test "new_application_form_base_data with application" do
      application = FactoryBot.create(:cinstance)

      form_data = new_application_form_base_data(provider, application)

      expected_keys = %i[create-application-plan-path create-service-plan-path service-subscriptions-path service-plans-allowed defined-fields errors]
      unexpected_keys = %i[most-recently-updated-products products-count buyer product most-recently-created-buyers buyers-count]

      assert_same_elements expected_keys, form_data.keys
      unexpected_keys.each { |key| assert_does_not_contain form_data.keys, key }
    end

    test "buyers are limited to 20" do
      FactoryBot.create_list(:simple_buyer, 21, provider_account: provider)

      # TODO: change to 20 when SelectWithModal is updated https://github.com/3scale/porta/pull/2459
      assert_equal 21, buyers.size
    end

    test "products are limited to 20" do
      FactoryBot.create_list(:simple_service, 21, account: provider)

      # TODO: change to 20 when SelectWithModal is updated https://github.com/3scale/porta/pull/2459
      assert_equal 21, products.size
    end

    test "application_defined_fields_data" do
      field = FactoryBot.create(:fields_definition, account: provider, target: 'Cinstance')
      data = application_defined_fields_data(provider)

      assert_equal 1, data.size
      assert_equal "cinstance[#{field.name}]", data.first[:name]
    end
  end
end
