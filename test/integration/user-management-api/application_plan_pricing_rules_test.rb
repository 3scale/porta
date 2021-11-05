# frozen_string_literal: true

require 'test_helper'

class Admin::Api::ApplicationPlanPricingRulesTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account, domain: 'provider.example.com')
    @service  = FactoryBot.create(:service, account: @provider)
    @app_plan = FactoryBot.create(:application_plan, issuer: @service)
    @metric   = FactoryBot.create(:metric, service: @service)
    @pricing_rule = FactoryBot.create(:pricing_rule, plan: @app_plan, metric: @metric)

    host! @provider.admin_domain
  end

  class AccessTokenTest < Admin::Api::ApplicationPlanPricingRulesTest
    def setup
      super
      user = FactoryBot.create(:member, account: @provider, admin_sections: %w[partners plans])
      @token = FactoryBot.create(:access_token, owner: user, scopes: 'account_management')
    end

    context 'without access to all services' do
      setup do
        User.any_instance.stubs(:has_access_to_all_services?).returns(false)
      end

      should 'index with no token' do
        get admin_api_application_plan_pricing_rules_path(@app_plan)
        assert_response :forbidden
      end

      should 'index with access to no services' do
        User.any_instance.expects(:member_permission_service_ids).returns([]).at_least_once
        get admin_api_application_plan_pricing_rules_path(@app_plan), params: params
        assert_response :not_found
      end

      should 'index with access to some service' do
        User.any_instance.expects(:member_permission_service_ids).returns([@service.id]).at_least_once
        get admin_api_application_plan_pricing_rules_path(@app_plan), params: params
        assert_response :success
      end
    end

    context 'with access to all services' do
      setup do
        User.any_instance.stubs(:has_access_to_all_services?).returns(true)
      end

      should 'index' do
        User.any_instance.expects(:member_permission_service_ids).never
        get admin_api_application_plan_pricing_rules_path(@app_plan), params: params
        assert_response :success
      end
    end

    private

    def access_token_params(token = @token)
      { access_token: token.value }
    end

    alias params access_token_params
  end

  class ProviderKeyTest < Admin::Api::ApplicationPlanPricingRulesTest
    test 'application_plan not found' do
      get admin_api_application_plan_pricing_rules_path(application_plan_id: 0, format: :xml), params: params
      assert_response :not_found
    end

    test 'application_plan_pricing_rules_index' do
      get admin_api_application_plan_pricing_rules_path(application_plan_id: @app_plan, format: :xml), params: params
      assert_response :success
      assert_pricing_rules(body, { plan_id: @app_plan.id, metric_id: @metric.id })
    end

    private

    def provider_key_params
      { provider_key: @provider.api_key }
    end

    alias params provider_key_params
  end
end
