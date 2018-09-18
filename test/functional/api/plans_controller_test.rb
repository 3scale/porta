require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Api::PlansControllerTest < ActionController::TestCase

  def setup
    @provider = Factory :provider_account
    login_provider @provider
  end

  # Airbrake: https://3scale.airbrake.io/groups/55535047
  # Github: https://github.com/3scale/system/issues/2179
  test "publishing a published application plan" do
    app_plan = Factory :published_plan, :issuer => @provider.default_service

    post :publish, id: app_plan.id

    assert_response :redirect
    assert_redirected_to admin_service_application_plans_path(app_plan.service)
    assert_not_nil flash[:alert]
  end

  test "publishing a service plan and redirecting back to google" do
    service_plan = Factory :service_plan, :issuer => @provider.default_service

    request.env["HTTP_REFERER"] = "http://google.com"

    post :publish, id: service_plan.id

    assert_response :redirect
    assert_redirected_to "http://google.com"
    assert_not_nil flash[:notice]
    assert assigns(:plan).published?
  end

  test "hiding an account plan" do

    post :hide, id: @provider.default_account_plan.id

    assert_response :redirect
    assert_redirected_to admin_account_plans_path
    assert_not_nil flash[:notice]
    assert assigns(:plan).hidden?
  end
end
