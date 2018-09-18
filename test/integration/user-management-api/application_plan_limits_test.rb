require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Admin::Api::ApplicationPlanLimitsTest < ActionDispatch::IntegrationTest
  def setup
    @provider = Factory :provider_account, :domain => 'provider.example.com'
    @service  = Factory :service, :account => @provider
    @app_plan = Factory :application_plan, :issuer => @service
    @metric   = Factory :metric, :service => @service
    @limit    = Factory :usage_limit, :plan => @app_plan, :metric => @metric


    host! @provider.admin_domain
  end

  # Access token

  test 'index (access_token)' do
    User.any_instance.stubs(:has_access_to_all_services?).returns(false)
    user  = FactoryGirl.create(:member, account: @provider, admin_sections: ['partners', 'plans'])
    token = FactoryGirl.create(:access_token, owner: user, scopes: 'account_management')

    get(admin_api_application_plan_limits_path(@app_plan))
    assert_response :forbidden
    get(admin_api_application_plan_limits_path(@app_plan), access_token: token.value)
    assert_response :not_found
    User.any_instance.expects(:member_permission_service_ids).returns([@service.id]).at_least_once
    get(admin_api_application_plan_limits_path(@app_plan), access_token: token.value)
    assert_response :success
  end

  # Provider key

  test 'application_plan not found' do
    get(admin_api_application_plan_limits_path(:application_plan_id => 0),
             :provider_key => @provider.api_key, :format => :xml)

    assert_response :not_found
  end


  test 'application_plan_limits_index' do
    get(admin_api_application_plan_limits_path(@app_plan),
             :provider_key => @provider.api_key, :format => :xml)

    assert_response :success

    assert_usage_limits(@response.body, {
                          :plan_id => @app_plan.id,
                          :metric_id => @metric.id })
  end
end
