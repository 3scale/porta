# frozen_string_literal: true

require 'test_helper'

class Buyers::ApplicationsTest < ActionDispatch::IntegrationTest
  class TenantLoggedInTest < Buyers::ApplicationsTest
    setup do
      @provider = FactoryBot.create(:provider_account)
      login! @provider
    end

    attr_reader :provider

    class Create < TenantLoggedInTest
      def setup
        @service = provider.default_service
        @application_plan = FactoryBot.create(:application_plan, issuer: service)
        @service_plan = FactoryBot.create(:service_plan, service: service)
        @buyer = FactoryBot.create(:buyer_account, provider_account: provider)
      end

      attr_reader :service_plan, :buyer, :application_plan, :service

      test 'crate application redirects to the provider admin index page' do
        post admin_buyers_account_applications_path(buyer), params: { cinstance: { service_plan_id: service_plan.id, plan_id: application_plan.id, name: 'My Application' } }

        assert_redirected_to provider_admin_application_path(Cinstance.last)
      end

      test 'crate application with no service plan selected' do
        post admin_buyers_account_applications_path(buyer), params: { cinstance: { plan_id: application_plan.id, name: 'My Application' } }

        application = Cinstance.last
        assert_redirected_to provider_admin_application_path(application)
      end

      test 'crate application with no service plan selected and a default service plan' do
        default_service_plan = FactoryBot.create(:service_plan, service: service)
        service.update(default_service_plan: default_service_plan)
        post admin_buyers_account_applications_path(buyer), params: { cinstance: { plan_id: application_plan.id, name: 'My Application' } }

        assert_response :redirect
        assert_equal default_service_plan, buyer.bought_service_contracts.first.service_plan
      end

      test 'crate application with no service plan selected and no default service plan' do
        other_service_plan = FactoryBot.create(:service_plan, service: service)
        service.update(default_service_plan: nil)
        post admin_buyers_account_applications_path(buyer), params: { cinstance: { plan_id: application_plan.id, name: 'My Application' } }

        assert_response :redirect
        assert_not_equal other_service_plan, buyer.bought_service_contracts.first.service_plan
      end

      test 'crate application with no service plan selected and a subscription' do
        subscribed_service_plan = FactoryBot.create(:service_plan, service: service)
        buyer.bought_service_contracts.create(plan: subscribed_service_plan)
        post admin_buyers_account_applications_path(buyer), params: { cinstance: { plan_id: application_plan.id, name: 'My Application' } }

        assert_response :redirect
        assert_equal subscribed_service_plan, buyer.bought_service_contracts.first.service_plan
      end

      test 'member cannot create an application when lacking access to a service' do
        stub_backend_get_keys
        stub_backend_referrer_filters
        stub_backend_utilization

        forbidden_service = FactoryBot.create(:service, account: provider)
        forbidden_plan = FactoryBot.create(:application_plan, issuer: forbidden_service)
        forbidden_service_plan = FactoryBot.create(:service_plan, issuer: forbidden_service)

        authorized_service = FactoryBot.create(:service, account: provider)
        authorized_plan = FactoryBot.create(:application_plan, issuer: authorized_service)
        authorized_service_plan = FactoryBot.create(:service_plan, issuer: authorized_service)

        member = FactoryBot.create(:member, account: provider, member_permission_ids: [:partners])
        member.activate!
        FactoryBot.create(:member_permission, user: member, admin_section: :services, service_ids: [authorized_service.id])

        login_provider provider, user: member

        post admin_buyers_account_applications_path(buyer), params: { cinstance: { service_plan_id: forbidden_service_plan.id, plan_id: forbidden_plan.id, name: 'Not Allowed!' } }

        assert_response :not_found

        post admin_buyers_account_applications_path(buyer), params: { cinstance: { service_plan_id: authorized_service_plan.id, plan_id: authorized_plan.id, name: 'Allowed' } }

        assert_response :found
      end
    end
  end
end
