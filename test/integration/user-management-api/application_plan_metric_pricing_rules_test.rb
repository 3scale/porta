# frozen_string_literal: true

require 'test_helper'

class Admin::Api::ApplicationPlanMetricPricingRulesTest < ActionDispatch::IntegrationTest
  include ThreeScale::PrivateModule(System::UrlHelpers.system_url_helpers)

  def setup
    @provider = FactoryBot.create(:provider_account, domain: 'provider.example.com')
    @service = FactoryBot.create(:service, account: @provider)
    @app_plan = FactoryBot.create(:application_plan, issuer: @service)
    @metric = FactoryBot.create(:metric, owner: @service)
    @pricing_rule = FactoryBot.create(:pricing_rule, plan: @app_plan, metric: @metric)

    host! @provider.external_admin_domain
  end

  class AccessTokenTest < Admin::Api::ApplicationPlanMetricPricingRulesTest
    def setup
      super
      user = FactoryBot.create(:member, account: @provider, admin_sections: ['partners'])
      @token = FactoryBot.create(:access_token, owner: user, scopes: 'account_management')

      User.any_instance.stubs(:has_access_to_all_services?).returns(false)
    end

    test 'index with no token' do
      get admin_api_application_plan_metric_pricing_rules_path(@app_plan, @metric.id)
      assert_response :forbidden
    end

    test 'index with access to no services' do
      User.any_instance.expects(:member_permission_service_ids).returns([]).at_least_once
      get admin_api_application_plan_metric_pricing_rules_path(@app_plan, @metric.id), params: params
      assert_response :not_found
    end

    test 'index with access to some service' do
      User.any_instance.expects(:member_permission_service_ids).returns([@service.id]).at_least_once
      get admin_api_application_plan_metric_pricing_rules_path(@app_plan, @metric.id), params: params
      assert_response :success
    end

    test 'index with access to all services' do
      User.any_instance.stubs(:has_access_to_all_services?).returns(true)
      User.any_instance.expects(:member_permission_service_ids).never
      get admin_api_application_plan_metric_pricing_rules_path(@app_plan, @metric.id), params: params
      assert_response :success
    end

    private

    def access_token_params(token = @token)
      { access_token: token.value }
    end

    alias params access_token_params
  end

  class ProviderKeyTest < Admin::Api::ApplicationPlanMetricPricingRulesTest
    test 'application_plan not found' do
      get admin_api_application_plan_metric_pricing_rules_path(application_plan_id: 0, metric_id: @metric.id, format: :xml), params: params
      assert_response :not_found
    end

    test 'application metric not found' do
      get admin_api_application_plan_metric_pricing_rules_path(application_plan_id: @app_plan.id, metric_id: 0, format: :xml), params: params
      assert_response :not_found
    end

    test 'application_plan_metric_pricing_rules_index' do
      get admin_api_application_plan_metric_pricing_rules_path(application_plan_id: @app_plan, metric_id: @metric.id, format: :xml), params: params
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
