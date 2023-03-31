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

      test 'index does not show the services column regardless of provider being multiservice' do
        provider.services.create!(name: '2nd-service')
        assert provider.reload.multiservice?
        get admin_service_applications_path(service)
        page = Nokogiri::HTML4::Document.parse(response.body)
        refute page.xpath("//tr").text.match /Service/
      end
    end

    class Create < TenantLoggedInTest
      def setup
        @service = provider.default_service
        @application_plan = FactoryBot.create(:application_plan, issuer: service)
        @service_plan = FactoryBot.create(:service_plan, service: service)
        @buyer = FactoryBot.create(:buyer_account, provider_account: provider)
      end

      attr_reader :service_plan, :buyer, :application_plan, :service

      test 'crate application redirects to the provider admin index page' do
        post admin_service_applications_path(service), params: { account_id: buyer.id,
                                                                 cinstance: { service_plan_id: service_plan.id, plan_id: application_plan.id, name: 'My Application' } }

        assert_redirected_to provider_admin_application_path(Cinstance.last)
      end

      test 'crate application with no service plan selected' do
        post admin_service_applications_path(service), params: { account_id: buyer.id,
                                                                 cinstance: { plan_id: application_plan.id, name: 'My Application' } }

        application = Cinstance.last
        assert_redirected_to provider_admin_application_path(application)
      end

      test 'crate application with no service plan selected and a default service plan' do
        default_service_plan = FactoryBot.create(:service_plan, service: service)
        service.update(default_service_plan: default_service_plan)
        post admin_service_applications_path(service), params: { account_id: buyer.id,
                                                                 cinstance: { plan_id: application_plan.id, name: 'My Application' } }

        assert_response :redirect
        assert_equal default_service_plan, buyer.bought_service_contracts.first.service_plan
      end

      test 'crate application with no service plan selected and no default service plan' do
        other_service_plan = FactoryBot.create(:service_plan, service: service)
        service.update(default_service_plan: nil)
        post admin_service_applications_path(service), params: { account_id: buyer.id,
                                                                 cinstance: { plan_id: application_plan.id, name: 'My Application' } }

        assert_response :redirect
        assert_not_equal other_service_plan, buyer.bought_service_contracts.first.service_plan
      end

      test 'crate application with no service plan selected and a subscription' do
        subscribed_service_plan = FactoryBot.create(:service_plan, service: service)
        buyer.bought_service_contracts.create(plan: subscribed_service_plan)
        post admin_service_applications_path(service), params: { account_id: buyer.id,
                                                                 cinstance: { plan_id: application_plan.id, name: 'My Application' } }

        assert_response :redirect
        assert_equal subscribed_service_plan, buyer.bought_service_contracts.first.service_plan
      end
    end
  end

end
