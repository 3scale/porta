require 'test_helper'

class Provider::Admin::Dashboard::Service::HitsControllerTest < ActionController::TestCase
  setup do
    @provider = FactoryBot.create(:provider_account)
    login_provider(@provider)
  end

  test "should get show" do
    xhr :get, :show, service_id: FactoryBot.create(:simple_service, account: @provider)
    assert_response :success
  end
end
