# frozen_string_literal: true

require 'test_helper'

class Admin::Api::ApplicationPlanLimitsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:provider_account)
    @token = FactoryBot.create(:access_token, owner: @provider.admin_users.first!, scopes: %w[account_management]).value
    host! @provider.admin_domain
  end

  def test_index
    service = FactoryBot.create(:simple_service, account: @provider)
    app_plan = FactoryBot.create(:simple_application_plan, issuer: service)
    metric = FactoryBot.create(:metric, service: service)
    metric.usage_limits.create(period: :week, value: 1, plan: app_plan)
    metric.usage_limits.create(period: :month, value: 1, plan: app_plan)

    get admin_api_application_plan_limits_path(app_plan, format: :json, access_token: @token)
    assert_response :success
    assert_equal 2, JSON.parse(response.body)['limits'].length

    get admin_api_application_plan_limits_path(app_plan, per_page: 1, format: :json, access_token: @token)
    assert_response :success
    assert_equal 1, JSON.parse(response.body)['limits'].length

    get admin_api_application_plan_limits_path(app_plan, per_page: 2, page: 2, format: :json, access_token: @token)
    assert_response :success
    assert_equal 0, JSON.parse(response.body)['limits'].length
  end
end
