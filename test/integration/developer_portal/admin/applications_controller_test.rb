# frozen_string_literal: true

require 'test_helper'

class DeveloperPortal::Admin::ApplicationsControllerTest < ActionDispatch::IntegrationTest
  include System::UrlHelpers.cms_url_helpers

  def setup
    @provider = FactoryBot.create(:provider_account)
    @service = @provider.default_service

    @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
    @buyer.buy! @service.service_plans.first

    @plan = FactoryBot.create(:application_plan, issuer: @service)
    @plan.publish!

    @buyer.buy! @plan
    @buyer.reload

    host! @provider.domain
  end

  class SingleAppModeTest < DeveloperPortal::Admin::ApplicationsControllerTest
    def setup
      super
      authorization_test_setup
      assert @provider.settings.multiple_applications_denied?
    end

    class ManageAppsDisabledTest < SingleAppModeTest
      def setup
        super
        @service.update(buyers_manage_apps: false)
      end

      test 'grant access to index' do
        get admin_applications_path
        assert_response :success
      end

      test 'grant access to show' do
        @buyer_auth.buy! @plan
        @buyer_auth.reload

        get admin_application_path(@buyer_auth.bought_cinstance)
        assert_response :success
      end

      test 'deny access to new' do
        get new_admin_application_path
        assert_response :forbidden
      end

      test 'deny access to create' do
        post admin_applications_path(cinstance: { plan_id: @plan.id })
        assert_response :forbidden
      end

      test 'deny access to edit' do
        @buyer_auth.buy! @plan
        @buyer_auth.reload

        get edit_admin_application_path(@buyer_auth.bought_cinstance)
        assert_response :forbidden
      end

      test 'deny access to update' do
        @buyer_auth.buy! @plan
        @buyer_auth.reload

        put admin_application_path(@buyer_auth.bought_cinstance)
        assert_response :forbidden
      end

      test 'do not validate extra fields when only update redirect_to' do
        @buyer_auth.buy! @plan
        @buyer_auth.reload
        @provider.fields_definitions.create({"target"=>"Cinstance", "name"=>"lol", "label"=>"lol", "required"=>"1"})
        @service.update(buyers_manage_apps: true)
        cinstance = @buyer_auth.bought_cinstance
        @provider.settings.allow_multiple_applications!
        @provider.settings.show_multiple_applications!

        patch admin_application_url(cinstance), params: { application: { redirect_url: "http://example.com" } }
        cinstance.reload
        assert_equal 'http://example.com', cinstance.redirect_url
      end

      test 'validate extra fields' do
        @buyer_auth.buy! @plan
        @buyer_auth.reload
        @provider.fields_definitions.create({"target"=>"Cinstance", "name"=>"lol", "label"=>"lol", "required"=>"1"})
        @service.update(buyers_manage_apps: true)
        cinstance = @buyer_auth.bought_cinstance
        @provider.settings.allow_multiple_applications!
        @provider.settings.show_multiple_applications!

        patch admin_application_url(cinstance), params: { application: { redirect_url: "http://example.com", name: "foo" } }
        assert assigns(:cinstance).errors[:lol].present?
      end
    end

    class ManageAppsEnabledTest < SingleAppModeTest
      def setup
        super
        @service.update(buyers_manage_apps: true)
      end

      test 'allow access to new' do
        get new_admin_application_path
        assert_response :success
      end

      test 'deny access to new if apps exist' do
        @buyer_auth.buy! @plan
        @buyer_auth.reload

        get new_admin_application_path
        assert_response :forbidden
      end

      test 'allow access to create' do
        post admin_applications_path(cinstance: { plan_id: @plan.id, name: 'my app' })

        assert_response :redirect
        assert @buyer_auth.bought_cinstance
      end

      test 'enforce strong parameters on create' do
        assert_nothing_raised do
          post admin_applications_path(cinstance: { plan_id: @plan.id, name: 'my app', description: 'this is my new app', org_name: 'not allowed' })
          assert_response :redirect
        end
      end

      test 'deny access to create more apps' do
        @buyer_auth.buy! @plan
        @buyer_auth.reload

        post admin_applications_path(cinstance: { plan_id: @plan.id })
        assert_response :forbidden
      end

      test 'allow access to edit' do
        @buyer_auth.buy! @plan
        @buyer_auth.reload

        get edit_admin_application_path(@buyer_auth.bought_cinstance)
        assert_response :success
      end

      test 'allow access to update' do
        @buyer_auth.buy! @plan
        @buyer_auth.reload

        put admin_application_url(@buyer_auth.bought_cinstance), params: { cinstance: { name: "updated" } }
        assert_response :redirect
        assert_equal "updated", @buyer_auth.bought_cinstance.name
      end
    end
  end

  class MultiAppModeTest < DeveloperPortal::Admin::ApplicationsControllerTest
    def setup
      super
      authorization_test_setup
      @provider.settings.allow_multiple_applications!
      @provider.settings.show_multiple_applications!

      @buyer_auth.buy! @plan # buyer has an app already!
    end

    class ManageAppsDisabledTest < MultiAppModeTest
      def setup
        super
        @service.update(buyers_manage_apps: false)
      end

      test 'grant access to index' do
        get admin_applications_path
        assert_response :success
      end

      test 'grant access to show' do
        get admin_application_path(@buyer_auth.bought_cinstance)
        assert_response :success
      end

      test 'deny access to new' do
        get new_admin_application_path
        assert_response :forbidden
      end

      test 'deny access to create' do
        post admin_applications_path(cinstance: { plan_id: @plan.id })
        assert_response :forbidden
      end

      test 'deny access to edit' do
        get edit_admin_application_path(@buyer_auth.bought_cinstance)
        assert_response :forbidden
      end

      test 'deny access to update' do
        put admin_application_path(@buyer_auth.bought_cinstance)
        assert_response :forbidden
      end
    end

    class ManageAppsEnabledTest < MultiAppModeTest
      def setup
        super
        @service.update(buyers_manage_apps: true)
      end

      test 'allow access to new' do
        get new_admin_application_path
        assert_response :success
      end

      test 'allow access to create' do
        new_plan  = FactoryBot.create :application_plan, issuer: @service
        post admin_applications_path(cinstance: { plan_id: new_plan.id, name: 'App name', description: 'Desc' })

        assert_response :redirect
        assert @buyer_auth.bought_cinstance
      end

      test 'allow access to edit' do
        get edit_admin_application_path(@buyer_auth.bought_cinstance)
        assert_response :success
      end

      test 'allow access to update' do
        put admin_application_url(@buyer_auth.bought_cinstance), params: { cinstance: { name: "updated" } }
        assert_response :redirect
        assert_equal "updated", @buyer_auth.bought_cinstance.name
      end

      test 'destroy the application' do
        assert_difference @buyer_auth.bought_cinstances.method(:count), -1 do
          delete admin_application_path(@buyer_auth.bought_cinstance)
        end
      end

      test 'no default nor published application plan' do
        @service.application_plans.each(&:hide!)

        get new_admin_application_path(service_id: @service.id)
        assert_response :not_found
      end

      test 'open new app form' do
        get new_admin_application_path(service_id: @service.id)
        assert_response :success
      end
    end
  end

  def authorization_test_setup
    @buyer_auth = FactoryBot.create(:buyer_account, provider_account: @provider)
    @buyer_auth.buy! @service.service_plans.first
    login_buyer @buyer_auth
  end
end
