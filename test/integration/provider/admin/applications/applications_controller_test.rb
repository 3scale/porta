# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::ApplicationsTest < ActionDispatch::IntegrationTest
  class MasterLoggedInTest < Provider::Admin::ApplicationsTest
    attr_reader :service

    setup do
      login! master_account
      @service = master_account.default_service
      FactoryBot.create(:cinstance, service: service)
    end

    test 'index retrieves all master\'s provided cinstances except those whose buyer is master' do
      get provider_admin_applications_path

      assert_response :ok
      page = Nokogiri::HTML4::Document.parse(response.body)
      expected_cinstances_ids = master_account.provided_cinstances.not_bought_by(master_account).pluck(:id)
      expected_cinstances_ids.each do |id|
        assert page.xpath %(//tbody[@class="cinstances"]//tr[contains(@id, "#{id}")])
      end
    end

    test 'show is visible for all master\'s provided cinstances except those whose buyer is master' do
      buyer_master, provider_master = service.cinstances.partition { |cinstance| cinstance.user_account_id == Account.master.id }
      buyer_master.each do |buyer_cinstance|
        get provider_admin_application_path(buyer_cinstance)
        assert_response :not_found
      end
      provider_master.each do |provider_cinstance|
        get provider_admin_application_path(provider_cinstance)
        assert_response :ok
      end
    end
  end

  class ProviderLoggedInTest < Provider::Admin::ApplicationsTest
    setup do
      @provider = FactoryBot.create(:provider_account)
      login! @provider
    end

    attr_reader :provider

    class Index < ProviderLoggedInTest
      setup do
        @service = provider.services.first!
        plans = FactoryBot.create_list(:application_plan, 2, service: @service)
        buyers = FactoryBot.create_list(:buyer_account, 2, provider_account: provider)
        plans.each_with_index { |plan, index| buyers[index].buy! plan }
      end

      attr_reader :service

      test 'index shows the services column when the provider is multiservice' do
        provider.services.create!(name: '2nd-service')
        assert provider.reload.multiservice?
        get provider_admin_applications_path
        page = Nokogiri::HTML4::Document.parse(response.body)
        assert page.xpath '//thead/tr/td[text() = "Service"]'
      end

      test 'index does not show the services column when the provider is not multiservice' do
        assert_not provider.reload.multiservice?
        get provider_admin_applications_path
        page = Nokogiri::HTML4::Document.parse(response.body)
        assert_empty page.xpath '//thead/tr/td[text() = "Service"]'
      end

      test 'index shows an application of a custom plan' do
        service = provider.default_service
        buyer = FactoryBot.create(:buyer_account, provider_account: provider)
        app_plan = FactoryBot.create(:application_plan, issuer: service)
        custom_plan = app_plan.customize
        cinstance = FactoryBot.create(:cinstance, user_account: buyer, plan: custom_plan, name: 'my custom cinstance')

        get provider_admin_applications_path
        assert_response :success
        page = Nokogiri::HTML4::Document.parse(response.body)
        assert page.xpath('//tbody[@class="cinstances"]/tr').text.include? cinstance.display_name
      end
    end

    class Show < ProviderLoggedInTest
      setup do
        plan = FactoryBot.create(:application_plan, issuer: provider.default_service)
        @application = FactoryBot.create(:cinstance, plan: plan)
      end

      attr_reader :application

      test 'show plan widget features are drawn correctly' do
        service = provider.default_service
        feature = FactoryBot.create(:feature, featurable: service, name: 'ticked')
        application.plan.features_plans.create!(feature: feature)
        FactoryBot.create(:feature, featurable: service, name: 'crossed')

        get provider_admin_application_path(application)

        assert_response :success

        page = Nokogiri::HTML4::Document.parse(response.body)
        assert page.xpath("//tr[@class='feature enabled']").text.include? 'ticked'
        assert page.xpath("//tr[@class='feature disabled']").text.include? 'crossed'
      end

      test 'show plan of the app does not show in the plans select' do
        application.customize_plan! # maybe not needed, but we are checking even that custom does not appear

        get provider_admin_application_path(application)
        assert_response :success

        page = Nokogiri::HTML4::Document.parse(response.body)
        assert page.xpath("//select[@id='cinstance_plan_id']/option").map(&:text).exclude?(application.plan.name)
      end

      test 'shows renders app and a message for utilization when backend is not available' do
        get provider_admin_application_path(application)
        assert_response :success
        assert_match 'was a problem getting utilization', response.body
      end

      test 'shows renders app and a message for utilization when backend result is nil' do
        ThreeScale::Core::Utilization.expects(:load).with(application.service.backend_id, application.application_id).returns(nil)
        # BackendClient::Application.any_instance.expects(:utilization).returns(nil)

        get provider_admin_application_path(application)

        assert_response :success
        assert_match 'This is an unmetered application, there are no limits defined', response.body
      end

      test 'show renders application for the permitted services ids when there is no access to all services' do
        second_service = FactoryBot.create(:simple_service, account: provider)
        second_plan = FactoryBot.create(:application_plan, issuer: second_service)
        second_app = FactoryBot.create(:cinstance, plan: second_plan)

        User.any_instance.expects(:has_access_to_all_services?).returns(false).at_least_once
        User.any_instance.expects(:member_permission_service_ids).returns([application.issuer.id]).at_least_once
        get provider_admin_application_path(application)
        assert_response :success
        get provider_admin_application_path(second_app)
        assert_response :not_found
      end
    end

    class Create < ProviderLoggedInTest
      def setup
        @service = provider.default_service
        @application_plan = FactoryBot.create(:application_plan, issuer: service)
        @service_plan = FactoryBot.create(:service_plan, service: service)
        @buyer = FactoryBot.create(:buyer_account, provider_account: provider)
      end

      attr_reader :service_plan, :buyer, :application_plan, :service

      test 'crate application redirects to the provider admin index page' do
        post provider_admin_applications_path, params: { account_id: buyer.id,
                                                         cinstance: { plan_id: application_plan.id, service_plan_id: service_plan.id, name: 'My Application' } }

        assert_redirected_to provider_admin_application_path(Cinstance.last)
      end

      test 'crate application with no service plan selected' do
        post provider_admin_applications_path, params: { account_id: buyer.id,
                                                         cinstance: { plan_id: application_plan.id, name: 'My Application' } }

        application = Cinstance.last
        assert_redirected_to provider_admin_application_path(application)
      end

      test 'crate application with no service plan selected and a default service plan' do
        default_service_plan = FactoryBot.create(:service_plan, service: service)
        service.update(default_service_plan: default_service_plan)
        post provider_admin_applications_path, params: { account_id: buyer.id,
                                                         cinstance: { plan_id: application_plan.id, name: 'My Application' } }

        assert_response :redirect
        assert_equal default_service_plan, buyer.bought_service_contracts.first.service_plan
      end

      test 'crate application with no service plan selected and no default service plan' do
        other_service_plan = FactoryBot.create(:service_plan, service: service)
        service.update(default_service_plan: nil)
        post provider_admin_applications_path, params: { account_id: buyer.id,
                                                         cinstance: { plan_id: application_plan.id, name: 'My Application' } }

        assert_response :redirect
        assert_not_equal other_service_plan, buyer.bought_service_contracts.first.service_plan
      end

      test 'crate application with no service plan selected and a subscription' do
        subscribed_service_plan = FactoryBot.create(:service_plan, service: service)
        buyer.bought_service_contracts.create(plan: subscribed_service_plan)
        post provider_admin_applications_path, params: { account_id: buyer.id,
                                                         cinstance: { plan_id: application_plan.id, name: 'My Application' } }

        assert_response :redirect
        assert_equal subscribed_service_plan, buyer.bought_service_contracts.first.service_plan
      end
    end

    class Edit < ProviderLoggedInTest
      setup do
        plan = FactoryBot.create(:application_plan, issuer: provider.default_service)
        @application = FactoryBot.create(:cinstance, plan: plan, name: 'example-name', description: 'example-description')
      end

      attr_reader :application

      test 'edit renders correctly' do
        get edit_provider_admin_application_path(application)
        assert_response :success
        page = Nokogiri::HTML4::Document.parse(response.body)
        assert_equal 'example-name',  page.xpath("//input[@id='cinstance_name']").map { |node| node['value'] }.join
        assert_equal "\nexample-description", page.xpath("//textarea[@id='cinstance_description']").text
        assert_equal 1, page.xpath("//button[@type='submit']").length
      end
    end

    class ChangePlan < ProviderLoggedInTest
      include ActiveJob::TestHelper

      def setup
        @service = provider.default_service
        @initial_plan = FactoryBot.create(:application_plan, issuer: service)
        @new_plan = FactoryBot.create(:published_plan, issuer: service)
        buyer = FactoryBot.create(:buyer_account, provider_account: provider)
        @cinstance = FactoryBot.create(:cinstance, user_account: buyer, plan: initial_plan, paid_until: Date.new(2001,1,10))
      end

      attr_reader :service, :cinstance, :initial_plan, :new_plan

      test 'buying a stock plan is allowed but buying a custom plan is not' do
        app_plan = FactoryBot.create(:application_plan, issuer: service)
        custom_plan = app_plan.customize

        put change_plan_provider_admin_application_path(cinstance), params: { cinstance: { plan_id: custom_plan.id } }

        assert_response :not_found
        assert_equal initial_plan.id, cinstance.reload.plan_id

        put change_plan_provider_admin_application_path(cinstance), params: { cinstance: { plan_id: app_plan.id } }

        assert_redirected_to provider_admin_application_path(cinstance)
        assert_equal app_plan.id, cinstance.reload.plan_id
      end

      # Regression test of https://github.com/3scale/system/issues/1354
      test 'change plan should correctly mark paid_until' do
        cinstance.update_attribute(:trial_period_expires_at, nil)

        provider.timezone = 'Mountain Time (US & Canada)'
        provider.save!
        provider.settings.allow_finance!
        provider.reload.billing_strategy.update_attribute(:prepaid, true)

        travel_to(Date.new(2001,1,25)) do
          put change_plan_provider_admin_application_path(cinstance), params: { cinstance: { plan_id: new_plan.id } }
        end

        assert_response :redirect
        assert_equal cinstance.reload.plan, new_plan
        assert_equal Date.new(2001,1,31), cinstance.reload.paid_until.to_date
      end

      test 'change_plan should email provider with link to app page' do
        Logic::RollingUpdates.expects(skipped?: true).at_least_once

        ActionMailer::Base.deliveries = []
        perform_enqueued_jobs(only: ActionMailer::DeliveryJob) do
          put change_plan_provider_admin_application_path(cinstance), params: { cinstance: { plan_id: new_plan.id } }
        end

        assert_equal cinstance.reload.plan, new_plan
        assert mail = ActionMailer::Base.deliveries.first, 'missing email'
        assert_match provider_admin_application_url(cinstance, host: provider.internal_admin_domain), mail.body.to_s
      end

      #regression test for https://github.com/3scale/system/issues/1889
      test 'change plan should work even when cinstance misses description' do
        provider.settings.allow_multiple_applications!
        provider.settings.show_multiple_applications!

        put change_plan_provider_admin_application_path(cinstance), params: { cinstance: { plan_id: new_plan.id } }

        assert_response :redirect
        assert_equal cinstance.reload.plan, new_plan
      end
    end
  end
end
