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
        page = Nokogiri::HTML::Document.parse(response.body)
        refute page.xpath("//tr").text.match /Service/
      end
    end
  end

end
