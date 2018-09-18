# frozen_string_literal: true

require 'test_helper'

class Api::ApplicationPlansControllerTest < ActionDispatch::IntegrationTest

  setup do
    login! current_account
    @service = current_account.first_service!
  end

  class MasterLoggedInTest < Api::ApplicationPlansControllerTest
    setup do
      @plan = service.default_application_plan
    end

    test 'GET index shows the management buttons (create, delete, copy, hide/publish) for Saas' do
      management_buttons = [
        { element_text: 'Create Application Plan',
          xpath_selector: "//a[contains(@href, '#{new_admin_service_application_plan_path(service)}')]" },
        { element_text: /Hide/,
          xpath_selector: "//a[contains(@href, '#{hide_admin_plan_path(plan)}')]" },
        { element_text: /Copy/,
          xpath_selector: "//a[contains(@href, '#{admin_plan_copies_path(plan_id: plan.id)}')]" },
        { element_text: /Delete/,
          xpath_selector: "//a[contains(@href, '#{polymorphic_path([:admin, plan])}')]" }
      ]

      # Saas is the default
      get admin_service_application_plans_path(service)
      management_buttons.each do |button|
        assert_xpath(button[:xpath_selector], button[:element_text])
      end
    end

    test 'actions are authorized for Saas' do
      get admin_service_application_plans_path(service)
      assert_response :ok

      get new_admin_service_application_plan_path(service)
      assert_response :ok

      post admin_api_service_application_plans_path, name: 'planName'
      assert_response :created

      post hide_admin_plan_path(plan)
      assert_response :redirect

      post publish_admin_plan_path(plan)
      assert_response :redirect

      post admin_plan_copies_path(plan_id: plan.id, format: :js)
      assert_response :ok

      delete admin_application_plan_path(plan)
      assert_response :redirect
    end

    test 'actions are not authorized for on-prem' do
      ThreeScale.config.stubs(onpremises: true)
      ThreeScale.stubs(master_on_premises?: true)
      get admin_service_application_plans_path(service)
      assert_response :forbidden

      get new_admin_service_application_plan_path(service)
      assert_response :forbidden

      post admin_api_service_application_plans_path, name: 'planName'
      assert_response :forbidden

      post hide_admin_plan_path(plan)
      assert_response :forbidden

      post publish_admin_plan_path(plan)
      assert_response :forbidden

      post admin_plan_copies_path(plan_id: plan.id, format: :js)
      assert_response :forbidden

      delete admin_application_plan_path(plan)
      assert_response :forbidden
    end

    private

    def current_account
      master_account
    end
  end

  class ProviderLoggedInTest < Api::ApplicationPlansControllerTest
    setup do
      @plan = FactoryGirl.create(:application_plan, issuer: service)
    end

    test 'GET index shows always the management buttons (create, delete, copy, hide/publish) indepently of the onpremises value' do
      management_buttons = [
          { element_text: 'Create Application Plan',
            xpath_selector: "//a[contains(@href, '#{new_admin_service_application_plan_path(service)}')]" },
          { element_text: /Publish/,
            xpath_selector: "//a[contains(@href, '#{publish_admin_plan_path(plan)}')]" },
          { element_text: /Copy/,
            xpath_selector: "//a[contains(@href, '#{admin_plan_copies_path(plan_id: plan.id)}')]" },
          { element_text: /Delete/,
            xpath_selector: "//a[contains(@href, '#{polymorphic_path([:admin, plan])}')]" }
      ]

      [true, false].each do |onpremises|
        ThreeScale.config.stubs(onpremises: onpremises)
        get admin_service_application_plans_path(service)
        management_buttons.each do |button|
          assert_xpath(button[:xpath_selector], button[:element_text])
        end
      end
    end

    test 'Actions are always authorized' do
      [true, false].each do |onpremises|
        @plan = FactoryGirl.create(:application_plan, issuer: @service)
        ThreeScale.config.stubs(onpremises: onpremises)

        get new_admin_service_application_plan_path(service)
        assert_response :ok

        get new_admin_service_application_plan_path(service)
        assert_response :ok

        post admin_api_service_application_plans_path, name: "planName#{onpremises ? 'onprem' : 'saas'}"
        assert_response :created

        post publish_admin_plan_path(plan)
        assert_response :redirect

        post hide_admin_plan_path(plan)
        assert_response :redirect

        post admin_plan_copies_path(plan_id: plan.id, format: :js)
        assert_response :ok

        delete polymorphic_path([:admin, plan])
        assert_response :redirect
      end
    end

    private

    def current_account
      @current_account ||= FactoryGirl.create(:provider_account)
    end
  end

  private

  attr_reader :plan, :service

end
