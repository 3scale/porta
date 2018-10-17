require 'test_helper'

class Provider::Admin::Dashboard::NewAccountsControllerTest < ActionController::TestCase
  setup do
    @provider = FactoryGirl.create(:simple_admin).account
    login_provider(@provider)
  end

  test "should get show" do
    xhr :get, :show
    assert_response :success
  end
end
