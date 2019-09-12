# frozen_string_literal: true

require 'test_helper'

class Api::ServicesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @provider = FactoryBot.create(:provider_account)
    @service = @provider.default_service
    login! @provider
  end

  attr_reader :service, :provider

  class OldEmptyAttributesTest < Api::ServicesControllerTest
    test 'update with empty attributes' do
      skip 'it should fail right now for the "require" in the attributes'
      put admin_service_path(service), {}
      assert_response :redirect
    end
  end

  class SettingsTest < Api::ServicesControllerTest
    test 'settings renders the right template and contains the right sections' do
      get settings_admin_service_path(service)
      assert_response :success
      page = Nokogiri::HTML::Document.parse(response.body)

      assert_template 'api/services/settings'
      section_titles = page.xpath("//fieldset[@class='inputs']/legend").text
      ['Signup & Use', 'Application Plans', 'Application Plan Changing','Alerts'].each do |expected_title|
        section_titles.include? expected_title
      end
    end

    test 'update the settings' do
      put admin_service_path(service), update_params
      assert_equal 'Service information updated.', flash[:notice]

      update_service_params = update_params[:service]
      expected_notification_settings = update_service_params[:notification_settings].transform_values { |notifications| notifications.map(&:to_i) }
      expected_buyer_plan_change_permission = update_service_params[:buyer_plan_change_permission]
      expected_signup_and_use = update_service_params
                                  .slice(:intentions_required, :buyers_manage_apps, :referrer_filters_required, :custom_keys_enabled, :buyer_can_select_plan)
                                  .transform_values { |value| (value.to_i == 1) }

      service.reload

      assert_equal expected_notification_settings, service.notification_settings
      assert_equal expected_buyer_plan_change_permission, service.buyer_plan_change_permission
      expected_signup_and_use.each { |attr_name, attr_value| assert_equal attr_value, service.public_send(attr_name) }
    end

    # This test can be removed once used deprecated attributes have been removed from the schema
    test 'deprecated attributes should not be updated' do
      new_tech_support_email = 'foo.tech.support@example.com'
      new_admin_support_email = 'foo.admin.support@example.com'

      deprecated_update_params = { service:
                                   { tech_support_email: new_tech_support_email,
                                     admin_support_email: new_admin_support_email }
                                 }

      put admin_service_path(service), params: deprecated_update_params

      service.reload

      assert_not_equal service.tech_support_email, new_tech_support_email
      assert_not_equal service.admin_support_email, new_admin_support_email
    end

    private

    def update_params
      @update_params ||= { service:
        { intentions_required: '0',
          buyers_manage_apps: '0',
          referrer_filters_required: '1',
          custom_keys_enabled: '1',
          buyer_can_select_plan: '1',
          buyer_plan_change_permission: 'direct',
          notification_settings:
          { web_provider: ['', '50', '100', '300'],
            email_provider: ['', '50', '100', '150'],
            web_buyer: ['', '50', '100', '150'],
            email_buyer: ['', '50', '100', '300']
          }
        }
      }
    end
  end

  class BackendApiSelection < Api::ServicesControllerTest
    def setup
      super
      Logic::RollingUpdates.stubs(enabled?: true)
      Account.any_instance.stubs(:provider_can_use?).returns(false)
      provider.settings.allow_multiple_services!
    end

    test 'should not create a new Backend API if no option was selected' do
      assert_change of: -> { BackendApi.count }, by: 0 do
        post admin_services_path, service: {
          system_name: 'my_new_product',
          name: 'My new Product',
          description: 'This will act as product',
          backend_api: ''
        }
      end

      assert_equal 0, Service.last.backend_api_configs.count
    end

    test 'should create a new Backend API if Create New Backend Api was selected' do
      assert_change of: -> { BackendApi.count }, by: 1 do
        post admin_services_path, service: {
          system_name: 'my_new_product',
          name: 'My new Product',
          description: 'This will act as product',
          backend_api: 'new'
        }
      end

      assert_equal 1, Service.last.backend_api_configs.count
    end

    test 'should reuse the same Backend API if it was selected' do
      backend_api = FactoryBot.create(:backend_api, account: @provider)

      assert_change of: -> { BackendApi.count }, by: 0 do
        post admin_services_path, service: {
          system_name: 'my_new_product',
          name: 'My new Product',
          description: 'This will act as product',
          backend_api: backend_api.id
        }
      end

      assert_equal backend_api, Service.last.backend_api
      assert_equal 1, Service.last.backend_api_configs.count
    end

    test 'should not create Backend API if rolling update is not enabled' do
      Account.any_instance.stubs(:provider_can_use?).with(:api_as_product).returns(false).at_least_once

      assert_change of: -> { BackendApi.count }, by: 0 do
        post admin_services_path, service: {
          system_name: 'my_new_product',
          name: 'My new Product',
          description: 'This will act as product',
          backend_api: 'new'
        }
      end
      assert_equal 0, Service.last.backend_api_configs.count
    end
  end
end
