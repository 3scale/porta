require 'test_helper'

class Provider::Admin::Dashboard::Service::TopTrafficControllerTest < ActionController::TestCase
  setup do
    @provider = FactoryBot.create(:provider_account)
    login_provider(@provider)
  end

  test "should get show" do
    get :show, params: { service_id: FactoryBot.create(:simple_service, account: @provider) }, xhr: true
    assert_response :success
  end
end
