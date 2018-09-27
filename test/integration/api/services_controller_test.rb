# frozen_string_literal: true

require 'test_helper'

class Api::ServicesControllerTest < ActionDispatch::IntegrationTest

  class MasterAccount < Api::ServicesControllerTest
    setup do
      login! master_account
    end

    test 'GET index renders for Saas' do
      get admin_services_path
      assert_response :ok
      assert_template 'api/services/index'
    end

    test 'GET index is unauthorized for Master On-prem' do
      ThreeScale.stubs(master_on_premises?: true)
      get admin_services_path
      assert_response :forbidden
    end
  end

  class ProviderAccount < Api::ServicesControllerTest
    setup do
      provider = FactoryGirl.create(:provider_account)
      @service = provider.default_service
      login! provider
    end

    attr_reader :service

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

end
