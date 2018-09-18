require 'test_helper'

class Provider::Admin::Dashboard::Service::TopTrafficControllerTest < ActionController::TestCase
  setup do
    @provider = FactoryGirl.create(:provider_account)
    login_provider(@provider)
  end

  test "should get show" do
    xhr :get, :show, service_id: FactoryGirl.create(:simple_service, account: @provider)
    assert_response :success
  end
end
