# frozen_string_literal: true

require 'test_helper'

class Admin::Api::ApplicationPlanMetricLimitsTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create :provider_account, :domain => 'provider.example.com'
    @service  = FactoryBot.create :service, :account => @provider
    @app_plan = FactoryBot.create :application_plan, :issuer => @service
    @metric   = FactoryBot.create :metric, :service => @service
    @limit    = FactoryBot.create :usage_limit, :plan => @app_plan, :metric => @metric

    host! @provider.admin_domain
  end

  # Access token

  test 'index (access_token)' do
    User.any_instance.stubs(:has_access_to_all_services?).returns(false)
    user  = FactoryBot.create(:member, account: @provider, admin_sections: ['partners', 'plans'])
    token = FactoryBot.create(:access_token, owner: user, scopes: 'account_management')

    get(admin_api_application_plan_metric_limits_path(@app_plan, @metric))
    assert_response :forbidden
    get(admin_api_application_plan_metric_limits_path(@app_plan, @metric), params: { access_token: token.value })
    assert_response :not_found
    User.any_instance.expects(:member_permission_service_ids).returns([@service.id]).at_least_once
    get(admin_api_application_plan_metric_limits_path(@app_plan, @metric), params: { access_token: token.value })
    assert_response :success
  end

  # Provider key

  test 'application_plan not found' do
    get(admin_api_application_plan_metric_limits_path(:application_plan_id => 0,
                                                           :metric_id => @metric.id), params: { :provider_key => @provider.api_key, :format => :xml })

    assert_response :not_found
  end

  test 'application metric not found' do
    get(admin_api_application_plan_metric_limits_path(:application_plan_id => @app_plan.id,
                                                    :metric_id => 0), params: { :provider_key => @provider.api_key, :format => :xml })

    assert_response :not_found
  end

  test 'application_plan_metric_limits_index' do
    #regression test to assert that only limits of this metric are returned
    another_metric = FactoryBot.create :metric, :service => @service
    alien_limit    = FactoryBot.create :usage_limit, :plan => @app_plan, :metric => another_metric

    get(admin_api_application_plan_metric_limits_path(@app_plan, @metric), params: { :provider_key => @provider.api_key, :format => :xml })

    assert_response :success

    assert_usage_limits(body, {
                          :plan_id => @app_plan.id,
                          :metric_id => @metric.id })
  end

  test 'application_plan_metric_limits_index with a backend api used by service returns success' do
    backend = FactoryBot.create(:backend_api)
    metric  = FactoryBot.create(:metric, owner: backend)
    FactoryBot.create(:backend_api_config, backend_api: backend, service: @app_plan.service)

    get(admin_api_application_plan_metric_limits_path(@app_plan, metric), params: { :provider_key => @provider.api_key, :format => :xml })

    assert_response :success
  end

  test 'application_plan_metric_limits_index with a backend api not used by service returns not found' do
    backend = FactoryBot.create(:backend_api)
    metric  = FactoryBot.create(:metric, owner: backend)

    get(admin_api_application_plan_metric_limits_path(@app_plan, metric), params: { :provider_key => @provider.api_key, :format => :xml })

    assert_response :not_found
  end

  test 'application_plan_metric_limit_show' do
    get(admin_api_application_plan_metric_limit_path(@app_plan, @metric, @limit), params: { :provider_key => @provider.api_key, :format => :xml })

    assert_response :success

    assert_usage_limit(body, {
                         :id => @limit.id,
                         :plan_id => @app_plan.id,
                         :metric_id => @metric.id })
  end

  test 'application_plan_plan_metric show not found' do
    get(admin_api_application_plan_metric_limit_path(:application_plan_id => @app_plan.id,
                                                          :metric_id => @metric.id,
                                                          :id => 0), params: { :provider_key => @provider.api_key, :format => :xml })

    assert_response :not_found
  end

  test 'application_plan_metric create' do
    post(admin_api_application_plan_metric_limits_path(@app_plan, @metric), params: { :provider_key => @provider.api_key, :format => :xml, :period => 'week', :value => 15 })

    assert_response :success

    assert_usage_limit(body, {
                         :plan_id => @app_plan.id, :metric_id => @metric.id,
                         :period => 'week', :value => 15
                       })

    metric_limit = @metric.usage_limits.last

    assert metric_limit.period == :week
    assert metric_limit.value  == 15
  end

  test 'application_plan_metric create errors' do
    post(admin_api_application_plan_metric_limits_path(@app_plan, @metric), params: { :provider_key => @provider.api_key, :format => :xml, :period => 'a-while' })

    assert_response :unprocessable_entity
    assert_xml_error body, "Period is invalid"
  end

  test 'application_plan_metric_limits update' do
    assert @limit.period != "month"
    assert @limit.value  != 20

    put("/admin/api/application_plans/#{@app_plan.id}/metrics/#{@metric.id}/limits/#{@limit.id}", params: { :provider_key => @provider.api_key, :format => :xml, :period => 'month', :value => "20" })


    assert_response :success
    assert_usage_limit(body,
                       { :plan_id => @app_plan.id,
                         :metric_id => @metric.id,
                         :period => "month", :value => "20" })

    @limit.reload
    #TODO: dry this assertions all over the tests
    assert @limit.period == :month
    assert @limit.value  == 20
  end

  test 'application_plan_metrics_limit update not found' do
    put("/admin/api/application_plans/#{@app_plan.id}/metrics/#{@metric.id}/limits/0", params: { :provider_key => @provider.api_key, :format => :xml })

    assert_response :not_found
  end

  test 'application_plan_metrics_limit update errors' do
    put("/admin/api/application_plans/#{@app_plan.id}/metrics/#{@metric.id}/limits/#{@limit.id}", params: { :provider_key => @provider.api_key, :format => :xml, :period => 'century' })

    assert_response :unprocessable_entity

    assert_xml_error body, "Period is invalid"
  end

  test 'application_plan_metrics_limit destroy' do
    delete("/admin/api/application_plans/#{@app_plan.id}/metrics/#{@metric.id}/limits/#{@limit.id}",
                :provider_key => @provider.api_key,
                :format => :xml, :method => "_destroy")

    assert_response :success
    assert_empty_xml body

    assert_raise ActiveRecord::RecordNotFound do
      @limit.reload
    end
  end

  test 'application_plan_metrics_limit destroy not found' do
    delete("/admin/api/application_plans/#{@app_plan.id}/metrics/#{@metric.id}/limits/0",
                :provider_key => @provider.api_key,
                :format => :xml, :method => "_destroy")

    assert_response :not_found
  end

end
