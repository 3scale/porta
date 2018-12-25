require 'test_helper'

class Provider::Admin::Dashboard::Service::HitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = FactoryBot.create(:provider_account)
    login! @provider
  end

  test "should get show" do
    service = FactoryBot.create(:simple_service, account: @provider)
    get provider_admin_dashboard_service_hits_path(service_id: service.id), xhr: true
    assert_response :success
  end
end
