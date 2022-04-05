# frozen_string_literal: true

require 'test_helper'

class Admin::Api::ApplicationPlanLimitsControllerTest < ActionDispatch::IntegrationTest
  attr_reader :service, :app_plan, :provider

  setup do
    @provider = FactoryBot.create(:provider_account)
    @token = FactoryBot.create(:access_token, owner: @provider.admin_users.first!, scopes: %w[account_management]).value
    host! @provider.external_admin_domain
    @service = FactoryBot.create(:simple_service, account: @provider)
    @app_plan = FactoryBot.create(:simple_application_plan, issuer: service)
  end

  test "index pagination" do
    populate

    get admin_api_application_plan_limits_path(app_plan, format: :json, access_token: @token)
    assert_response :success
    assert_equal 4, JSON.parse(response.body)['limits'].length

    get admin_api_application_plan_limits_path(app_plan, per_page: 1, format: :json, access_token: @token)
    assert_response :success
    assert_equal 1, JSON.parse(response.body)['limits'].length

    get admin_api_application_plan_limits_path(app_plan, per_page: 2, page: 3, format: :json, access_token: @token)
    assert_response :success
    assert_equal 0, JSON.parse(response.body)['limits'].length
  end

  test "index works with any kind of metrics and methods" do
    populate(owner: service)
    populate(owner: FactoryBot.create(:backend_api, account: provider))

    get admin_api_application_plan_limits_path(app_plan, format: :json, access_token: @token)
    assert_response :success
    assert_not_empty JSON.parse(response.body)['limits']
  end

  def populate(times = 1, owner: service)
    metrics = FactoryBot.create_list(:metric, times, owner: owner)
    methods = FactoryBot.create_list(:method, times, owner: owner)
    metrics.zip(methods).each do |metric, method|
      metric.usage_limits.create(period: :week, value: 1, plan: app_plan)
      metric.usage_limits.create(period: :month, value: 1, plan: app_plan)
      method.usage_limits.create(period: :week, value: 1, plan: app_plan)
      method.usage_limits.create(period: :month, value: 1, plan: app_plan)
    end
  end
end
