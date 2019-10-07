# frozen_string_literal: true

require 'test_helper'

class Api::ServicesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @provider = FactoryBot.create(:provider_account)
    @service = @provider.default_service
    login! @provider
  end

  attr_reader :service

  class SettingsTest < Api::ServicesControllerTest
    test 'settings renders the right template and contains the right sections' do
      Account.any_instance.stubs(:provider_can_use?).returns(true)
      rolling_update(:api_as_product, enabled: false)

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
      Account.any_instance.stubs(:provider_can_use?).returns(true)
      rolling_update(:api_as_product, enabled: false)

      service.update!(deployment_option: 'self_managed')
      put admin_service_path(service), update_params
      assert_equal 'Service information updated.', flash[:notice]

      update_service_params = update_params[:service]
      update_proxy_params = update_service_params.delete(:proxy_attributes)
      expected_notification_settings = update_service_params[:notification_settings].transform_values { |notifications| notifications.map(&:to_i) }
      expected_buyer_plan_change_permission = update_service_params[:buyer_plan_change_permission]
      expected_signup_and_use = update_service_params
                                  .slice(:intentions_required, :buyers_manage_apps, :referrer_filters_required, :custom_keys_enabled, :buyer_can_select_plan)
                                  .transform_values { |value| (value.to_i == 1) }

      service.reload

      assert_equal expected_notification_settings, service.notification_settings
      assert_equal expected_buyer_plan_change_permission, service.buyer_plan_change_permission
      expected_signup_and_use.each { |attr_name, attr_value| assert_equal attr_value, service.public_send(attr_name) }

      proxy = service.proxy
      update_proxy_params.each do |field_name, expected_value|
        assert_equal expected_value, proxy.public_send(field_name)
      end
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

    test 'update endpoint and sandbox endpoint with apicast custom url enabled' do
      Account.any_instance.stubs(:provider_can_use?).returns(true)
      rolling_update(:api_as_product, enabled: false)

      ThreeScale.config.stubs(:apicast_custom_url).returns(true)

      proxy = service.proxy
      proxy.update_columns(endpoint: 'http://old-api.example.com:8080',
                           sandbox_endpoint: 'http://old-api.staging.example.com:8080')

      put admin_service_path(service), update_params
      proxy.reload
      assert_equal 'Service information updated.', flash[:notice]
      assert_equal 'http://api.example.com:8080', proxy.endpoint
      assert_equal 'http://api.staging.example.com:8080', proxy.sandbox_endpoint
    end

    test 'update endpoint and sandbox endpoint with apicast custom url disabled' do
      Account.any_instance.stubs(:provider_can_use?).returns(true)
      rolling_update(:api_as_product, enabled: false)

      ThreeScale.config.stubs(:apicast_custom_url).returns(false)

      proxy = service.proxy
      proxy.update_columns(endpoint: 'http://old-api.example.com:8080',
                           sandbox_endpoint: 'http://old-api.staging.example.com:8080')

      # hosted apicast
      put admin_service_path(service), update_params
      proxy.reload
      assert_equal 'http://old-api.example.com:8080', proxy.endpoint
      assert_equal 'http://old-api.staging.example.com:8080', proxy.sandbox_endpoint

      # self-menaged apicast
      service.update!(deployment_option: 'self_managed')
      put admin_service_path(service), update_params
      proxy.reload
      assert_equal 'Service information updated.', flash[:notice]
      assert_equal 'http://api.example.com:8080', proxy.endpoint
      assert_equal 'http://api.staging.example.com:8080', proxy.sandbox_endpoint
    end

    test 'update settings with apiap' do
      Account.any_instance.stubs(:provider_can_use?).returns(true)
      rolling_update(:api_as_product, enabled: true)

      put admin_service_path(service), update_params
      assert_equal 'Product information updated.', flash[:notice]
    end

    test 'update api_backend with apiap' do
      proxy = service.proxy
      proxy.api_backend = 'http://old.backend'
      proxy.save!

      Account.any_instance.stubs(:provider_can_use?).returns(true)
      rolling_update(:api_as_product, enabled: true)

      put admin_service_path(service), update_params.deep_merge(service: { proxy_attributes: { api_backend: 'https://new.backend' } })
      assert_equal 'http://old.backend:80', proxy.reload.api_backend
    end

    test 'update api_backend without' do
      proxy = service.proxy
      proxy.api_backend = 'http://old.backend'
      proxy.save!

      Account.any_instance.stubs(:provider_can_use?).returns(true)
      rolling_update(:api_as_product, enabled: false)

      put admin_service_path(service), update_params.deep_merge(service: { proxy_attributes: { api_backend: 'https://new.backend' } })
      assert_equal 'Service information updated.', flash[:notice]
      assert_equal 'https://new.backend:443', proxy.reload.api_backend
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
          },
          proxy_attributes: {
            endpoint: 'http://api.example.com:8080',
            sandbox_endpoint: 'http://api.staging.example.com:8080'
          }
        }
      }
    end
  end

  class BackendApiCreation < Api::ServicesControllerTest
    def setup
      super
      Logic::RollingUpdates.stubs(enabled?: true)
      Account.any_instance.stubs(:provider_can_use?).returns(true)
      @provider.settings.allow_multiple_services!
    end

    test 'should not create the default Backend if API as Product is enabled' do
      Account.any_instance.stubs(:provider_can_use?).with(:api_as_product).returns(true).at_least_once

      assert_no_change of: -> { BackendApi.count } do
        post admin_services_path, service: {
          system_name: 'my_new_product',
          name: 'My new Product',
          description: 'This will act as product'
        }
      end

      assert_equal 0, Service.last.backend_api_configs.count
    end

    test 'should create the default Backend if API as Product is disabled' do
      Account.any_instance.stubs(:provider_can_use?).with(:api_as_product).returns(false).at_least_once

      assert_change of: -> { BackendApi.count }, by: 1 do
        post admin_services_path, service: {
          system_name: 'my_new_product',
          name: 'My new Product',
          description: 'This will act as product'
        }
      end

      assert_equal 1, Service.last.backend_api_configs.count
    end
  end
end
