require 'test_helper'

class Stats::ApplicationsTest < ActionDispatch::IntegrationTest

  def setup
    @provider    = FactoryGirl.create(:provider_account)
    @service     = @provider.default_service
    @plan        = FactoryGirl.create(:simple_application_plan, issuer: @service)
    @application = FactoryGirl.create(:simple_cinstance, plan: @plan)

    host! @provider.admin_domain
    login_provider @provider
  end

  def test_show
    get admin_buyers_stats_application_path(id: @application.id)
    assert_response :success

    User.any_instance.expects(:has_access_to_all_services?).returns(false).at_least_once
    get admin_buyers_stats_application_path(id: @application.id)
    assert_response :forbidden

    User.any_instance.expects(:member_permission_service_ids).returns([@service.id]).at_least_once
    get admin_buyers_stats_application_path(id: @application.id)
    assert_response :success
  end
end
