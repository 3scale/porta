# frozen_string_literal: true

require 'test_helper'

class Api::ApplicationsControllerTest < ActionDispatch::IntegrationTest

  class MasterLoggedInTest < Api::ApplicationsControllerTest
    setup do
      login! master_account
      @service = master_account.default_service
      FactoryBot.create(:cinstance, service: @service)
    end

    attr_reader :service

    test 'index retrieves all master\'s provided cinstances except those whose buyer is master' do
      get admin_service_applications_path(service)

      assert_response :ok
      expected_cinstances_ids = service.cinstances.where.has { user_account_id != Account.master.id }.pluck(:id)
      assert_same_elements expected_cinstances_ids, assigns(:cinstances).map(&:id)
    end

    test 'show is visible for all master\'s provided cinstances except those whose buyer is master' do
      buyer_master, provider_master = service.cinstances.partition { |cinstance| cinstance.user_account_id == Account.master.id }
      buyer_master.each do |buyer_cinstance|
        get admin_service_application_path(service, buyer_cinstance)
        assert_response :not_found
      end
      provider_master.each do |provider_cinstance|
        get admin_service_application_path(service, provider_cinstance)
        assert_response :ok
      end
    end
  end

  class TenantLoggedInTest < Api::ApplicationsControllerTest
    setup do
      @provider = FactoryBot.create(:provider_account)
      login! @provider
    end

    attr_reader :provider

    class Index < TenantLoggedInTest
      setup do
        @service = provider.services.first!
        plans = FactoryBot.create_list(:application_plan, 2, service: @service)
        buyers = FactoryBot.create_list(:buyer_account, 2, provider_account: provider)
        plans.each_with_index { |plan, index| buyers[index].buy! plan }
      end

      attr_reader :service

      test 'index retrieves all cinstances of a service' do
        get admin_service_applications_path(service)

        assert_response :ok
        assert_same_elements service.cinstances.pluck(:id), assigns(:cinstances).map(&:id)
      end

      test 'index can retrieve the cinstances of an application plan belonging to a service' do
        plan = service.application_plans.first!
        get admin_service_applications_path(service, {application_plan_id: plan.id})

        assert_response :ok
        assert_same_elements plan.cinstances.pluck(:id), assigns(:cinstances).map(&:id)
      end

      test 'index can retrieve the cinstances of a buyer account' do
        buyer = @provider.buyers.last!
        get admin_service_applications_path(service, {account_id: buyer.id})

        assert_response :ok
        assert_same_elements buyer.bought_cinstances.pluck(:id), assigns(:cinstances).map(&:id)
      end

      test 'index does not show the services column even when the provider is multiservice' do
        provider.services.create!(name: '2nd-service')
        assert provider.reload.multiservice?
        get admin_service_applications_path(service)
        page = Nokogiri::HTML::Document.parse(response.body)
        refute page.xpath("//tr").text.match /Service/
      end
    end

    class Show < TenantLoggedInTest
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

        get admin_service_application_path(application.service, application)

        assert_response :success

        page = Nokogiri::HTML::Document.parse(response.body)
        assert page.xpath("//tr[@class='feature enabled']").text  =~ /ticked/
        assert page.xpath("//tr[@class='feature disabled']").text =~ /crossed/
      end

      test 'show plan of the app does not show in the plans select' do
        application.customize_plan! # maybe not needed, but we are checking even that custom does not appear

        get admin_service_application_path(application.service, application)
        assert_response :success

        page = Nokogiri::HTML::Document.parse(response.body)
        assert page.xpath("//select[@id='cinstance_plan_id']/option").map(&:text).exclude?(application.plan.name)
      end

      test 'shows renders app and a message for utilization when backend is not available' do
        get admin_service_application_path(application.service, application)
        assert_response :success
        assert_match 'was a problem getting utilization', response.body
      end

      test 'shows renders app and a message for utilization when backend result is nil' do
        ThreeScale::Core::Utilization.expects(:load).with(application.service.backend_id, application.application_id).returns(nil)

        get admin_service_application_path(application.service, application)

        assert_response :success
        assert_match 'This is an unmetered application, there are no limits defined', response.body
      end

      test 'show renders application for the permitted services ids when there is no access to all services' do
        second_service = FactoryBot.create(:simple_service, account: provider)
        second_plan = FactoryBot.create(:application_plan, issuer: second_service)
        second_app = FactoryBot.create(:cinstance, plan: second_plan)

        User.any_instance.expects(:has_access_to_all_services?).returns(false).at_least_once
        User.any_instance.expects(:member_permission_service_ids).returns([application.issuer.id]).at_least_once
        get admin_service_application_path(application.service, application)
        assert_response :success
        get admin_service_application_path(second_app.service, second_app)
        assert_response :not_found
      end
    end

    class Edit < TenantLoggedInTest
      setup do
        plan = FactoryBot.create(:application_plan, issuer: provider.default_service)
        @application = FactoryBot.create(:cinstance, plan: plan, name: 'example-name', description: 'example-description')
      end

      attr_reader :application

      test 'edit renders correctly' do
        get edit_admin_service_application_path(application.service, application)
        assert_response :success
        page = Nokogiri::HTML::Document.parse(response.body)
        assert_equal 'example-name',  page.xpath("//input[@id='cinstance_name']").map { |node| node['value'] }.join
        assert_equal "\nexample-description", page.xpath("//textarea[@id='cinstance_description']").text
        assert_equal 1, page.xpath("//button[@type='submit']").length
      end
    end
  end

end
