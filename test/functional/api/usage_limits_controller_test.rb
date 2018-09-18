require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Api::UsageLimitsControllerTest < ActionController::TestCase


  def setup
    @provider_account = Factory :provider_account
    @plan = Factory(:application_plan, issuer: @provider_account.default_service)
    @metric = Factory(:metric, service: @provider_account.default_service)

    @request.host = @provider_account.admin_domain
    login_as(@provider_account.admins.first)
  end


  test "post create, should render correcty the flash notices" do
    xhr :post, :create, application_plan_id: @plan.to_param, metric_id: @metric.to_param, usage_limit: {period: 'eternity', value: 42}
    assert flash[:notice].present? # usage_limit created
    assert_response :success

    xhr :post, :create, application_plan_id: @plan.to_param, metric_id: @metric.to_param, usage_limit: {period: 'eternity', value: 43}
    refute flash[:notice].present? # not created, same period for same metric
    assert_response :success

    xhr :post, :create, application_plan_id: @plan.to_param, metric_id: @metric.to_param, usage_limit: {period: 'minute', value: 43}
    assert flash[:notice].present? # different period, ok
    assert_response :success
  end
end
