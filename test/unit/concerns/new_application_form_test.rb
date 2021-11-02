# frozen_string_literal: true

require 'test_helper'

class MyForm
  include NewApplicationForm

  def initialize(provider:, service_plans_management_visible:)
    @provider = provider
    @user = FactoryBot.create(:simple_user, account: @provider)
    @service_plans_management_visible = service_plans_management_visible
  end

  attr_reader :provider, :user

  def service_plans_management_visible?
    @service_plans_management_visible
  end
end

module Concerns
  class NewApplicationFormTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    def setup(**opts)
      @provider = FactoryBot.create(:simple_provider)
      @form = MyForm.new(provider: @provider, **opts)
    end

    attr_reader :provider, :form

    delegate :new_application_form_base_data,
             :buyers,
             :products,
             :application_defined_fields_data, to: :form

    class WithServicePlansManagementVisible < NewApplicationFormTest
      def setup
        super(service_plans_management_visible: true)
      end
    end

    class WithoutServicePlansManagementVisible < NewApplicationFormTest
      def setup
        super(service_plans_management_visible: false)
      end
    end

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
      assert_equal 20, buyers.size
    end

    test "products are limited to 20" do
      FactoryBot.create_list(:simple_service, 21, account: provider)
      assert_equal 20, products.size
    end

    test "application_defined_fields_data" do
      field = FactoryBot.create(:fields_definition, account: provider, target: 'Cinstance')
      data = application_defined_fields_data(provider)

      assert_equal 1, data.size
      assert_equal "cinstance[#{field.name}]", data.first[:name]
    end

    def self.runnable_methods
      Concerns::NewApplicationFormTest == self ? [] : super
    end
  end
end
