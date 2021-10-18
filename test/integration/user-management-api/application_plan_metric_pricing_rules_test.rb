# frozen_string_literal: true

require 'test_helper'

class Admin::Api::ApplicationPlanMetricPricingRulesTest < ActionDispatch::IntegrationTest

  include ThreeScale::PrivateModule(System::UrlHelpers.system_url_helpers)

  def setup
    @provider = FactoryBot.create :provider_account, :domain => 'provider.example.com'
    @service  = FactoryBot.create :service, :account => @provider
    @app_plan = FactoryBot.create :application_plan, :issuer => @service
    @metric   = FactoryBot.create :metric, :service => @service
    @pricing_rule = FactoryBot.create :pricing_rule, :plan => @app_plan, :metric => @metric


    host! @provider.admin_domain
  end

  # Access token

  test 'index (access_token)' do
    User.any_instance.stubs(:has_access_to_all_services?).returns(false)
    user  = FactoryBot.create(:member, account: @provider, admin_sections: ['partners'])
    token = FactoryBot.create(:access_token, owner: user, scopes: 'account_management')

    get(admin_api_application_plan_metric_pricing_rules_path(@app_plan, @metric.id))
    assert_response :forbidden
    get(admin_api_application_plan_metric_pricing_rules_path(@app_plan, @metric.id), params: { access_token: token.value })
    assert_response :not_found
    User.any_instance.expects(:member_permission_service_ids).returns([@service.id]).at_least_once
    get(admin_api_application_plan_metric_pricing_rules_path(@app_plan, @metric.id), params: { access_token: token.value })
    assert_response :success
  end

  # Provider key

  test 'application_plan not found' do
    get(admin_api_application_plan_metric_pricing_rules_path(:application_plan_id => 0,
                                                                  :metric_id => @metric.id), params: { :provider_key => @provider.api_key, :format => :xml })

    assert_response :not_found
  end

  test 'application metric not found' do
    get(admin_api_application_plan_metric_pricing_rules_path(:application_plan_id => @app_plan.id,
                                                             :metric_id => 0), params: { :provider_key => @provider.api_key, :format => :xml })

    assert_response :not_found
  end

  test 'application_plan_metric_pricing_rules_index' do
    get(admin_api_application_plan_metric_pricing_rules_path(:application_plan_id => @app_plan,
                                                                  :metric_id => @metric.id), params: { :provider_key => @provider.api_key, :format => :xml })

    assert_response :success

    assert_pricing_rules(body, {
                          :plan_id => @app_plan.id,
                          :metric_id => @metric.id })
  end

end
