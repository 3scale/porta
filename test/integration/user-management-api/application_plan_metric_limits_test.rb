# frozen_string_literal: true

require 'test_helper'

class Admin::Api::ApplicationPlanMetricLimitsTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account, domain: 'provider.example.com')
    @service = FactoryBot.create(:service, account: @provider)
    @app_plan = FactoryBot.create(:application_plan, issuer: @service)
    @metric = FactoryBot.create(:metric, service: @service)
    @limit = FactoryBot.create(:usage_limit, plan: @app_plan, metric: @metric)

    host! @provider.internal_admin_domain
  end

  class AccessTokenTest < Admin::Api::ApplicationPlanMetricLimitsTest
    def setup
      super
      user = FactoryBot.create(:member, account: @provider, admin_sections: %w[partners plans])
      @token = FactoryBot.create(:access_token, owner: user, scopes: 'account_management')

      User.any_instance.stubs(:has_access_to_all_services?).returns(false)
    end

    test 'index with no token' do
      get admin_api_application_plan_metric_limits_path(@app_plan, @metric)
      assert_response :forbidden
    end

    test 'index with access to no services' do
      User.any_instance.expects(:member_permission_service_ids).returns([]).at_least_once
      get admin_api_application_plan_metric_limits_path(@app_plan, @metric), params: params
      assert_response :not_found
    end

    test 'index with access to some service' do
      User.any_instance.expects(:member_permission_service_ids).returns([@service.id]).at_least_once
      get admin_api_application_plan_metric_limits_path(@app_plan, @metric), params: params
      assert_response :success
    end

    test 'index with access to all services' do
      User.any_instance.stubs(:has_access_to_all_services?).returns(true)
      User.any_instance.expects(:member_permission_service_ids).never
      get admin_api_application_plan_metric_limits_path(@app_plan, @metric), params: params
      assert_response :success
    end

    private

    def access_token_params(token = @token)
      { access_token: token.value }
    end

    alias params access_token_params
  end

  class ProviderKeyTest < Admin::Api::ApplicationPlanMetricLimitsTest
    test 'application_plan not found' do
      get admin_api_application_plan_metric_limits_path(application_plan_id: 0, metric_id: @metric.id), params: params
      assert_response :not_found
    end

    test 'application metric not found' do
      get admin_api_application_plan_metric_limits_path(application_plan_id: @app_plan.id, metric_id: 0, format: :xml), params: params
      assert_response :not_found
    end

    test 'application_plan_metric_limits_index only limits of this metric are returned' do
      # Regression test
      another_metric = FactoryBot.create(:metric, service: @service)
      FactoryBot.create(:usage_limit, plan: @app_plan, metric: another_metric)

      get admin_api_application_plan_metric_limits_path(@app_plan, @metric, format: :xml), params: params
      assert_response :success

      assert_usage_limits(body, { plan_id: @app_plan.id, metric_id: @metric.id })
    end

    test 'application_plan_metric_limits_index with a backend api used by service returns success' do
      backend = FactoryBot.create(:backend_api)
      metric = FactoryBot.create(:metric, owner: backend)
      FactoryBot.create(:backend_api_config, backend_api: backend, service: @app_plan.service)

      get admin_api_application_plan_metric_limits_path(@app_plan, metric, format: :xml), params: params
      assert_response :success
    end

    test 'application_plan_metric_limits_index with a backend api not used by service returns not found' do
      backend = FactoryBot.create(:backend_api)
      metric = FactoryBot.create(:metric, owner: backend)

      get admin_api_application_plan_metric_limits_path(@app_plan, metric, format: :xml), params: params
      assert_response :not_found
    end

    test 'application_plan_metric_limit_show' do
      get admin_api_application_plan_metric_limit_path(@app_plan, @metric, @limit, format: :xml), params: params
      assert_response :success

      assert_usage_limit(body, { id: @limit.id, plan_id: @app_plan.id, metric_id: @metric.id })
    end

    test 'application_plan_plan_metric show not found' do
      get admin_api_application_plan_metric_limit_path(application_plan_id: @app_plan.id, metric_id: @metric.id, id: 0, format: :xml), params: params
      assert_response :not_found
    end

    test 'application_plan_metric create' do
      post admin_api_application_plan_metric_limits_path(@app_plan, @metric, format: :xml), params: params.merge({ period: 'week', value: 15 })
      assert_response :success

      assert_usage_limit(body, { plan_id: @app_plan.id, metric_id: @metric.id, period: 'week', value: 15 })

      metric_limit = @metric.usage_limits.last
      assert_equal :week, metric_limit.period
      assert_equal 15, metric_limit.value
    end

    test 'application_plan_metric create errors' do
      post admin_api_application_plan_metric_limits_path(@app_plan, @metric, format: :xml), params: params.merge({ period: 'a-while' })

      assert_response :unprocessable_entity
      assert_xml_error body, "Period is invalid"
    end

    test 'application_plan_metric_limits update' do
      @limit.update(period: 'week', value: 10)

      put admin_api_application_plan_metric_limit_path(@app_plan, @metric, @limit), params: params.merge({ period: 'month', value: "20", format: :xml })
      assert_response :success
      assert_usage_limit(body, { plan_id: @app_plan.id, metric_id: @metric.id, period: "month", value: "20" })

      @limit.reload
      assert_equal :month, @limit.period
      assert_equal 20, @limit.value
    end

    test 'application_plan_metrics_limit update not found' do
      put admin_api_application_plan_metric_limit_path(@app_plan, @metric, id: 0, format: :xml), params: params
      assert_response :not_found
    end

    test 'application_plan_metrics_limit update errors' do
      put admin_api_application_plan_metric_limit_path(@app_plan, @metric, @limit, format: :xml), params: params.merge({ period: 'century' })
      assert_response :unprocessable_entity

      assert_xml_error body, "Period is invalid"
    end

    test 'application_plan_metrics_limit destroy' do
      delete admin_api_application_plan_metric_limit_path(@app_plan, @metric, @limit, format: :xml), params: params.merge({ method: "_destroy" })
      assert_response :success
      assert_empty_xml body

      assert_raise ActiveRecord::RecordNotFound do
        @limit.reload
      end
    end

    test 'application_plan_metrics_limit destroy not found' do
      delete admin_api_application_plan_metric_limit_path(@app_plan, @metric, id: 0, format: :xml), params: params.merge({ method: "_destroy" })
      assert_response :not_found
    end

    private

    def provider_key_params
      { provider_key: @provider.api_key }
    end

    alias params provider_key_params
  end
end
