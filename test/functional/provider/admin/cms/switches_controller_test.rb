require 'test_helper'

class Provider::Admin::CMS::SwitchesControllerTest < ActionController::TestCase

  def setup
    @provider = Factory(:provider_account)
    host! @provider.admin_domain
    login_as @provider.admins.first
  end

  test "should get list of switches" do
    Settings::Switch.any_instance.stubs(:allowed?).returns(true)

    get :index

    assert_response :success
  end

  test "show a  switch" do
    @provider.settings.update_attribute(:account_plans_switch,'hidden')

    xhr :get, :update, id: 'account_plans', format: :js
    assert_response :success

    assert @provider.settings.reload.switches[:account_plans].visible?, 'not visible'
  end
end
