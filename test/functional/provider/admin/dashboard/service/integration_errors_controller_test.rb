require 'test_helper'

class Provider::Admin::Dashboard::Service::IntegrationErrorsControllerTest < ActionController::TestCase
  setup do
    @provider = FactoryBot.create(:provider_account)
    login_provider(@provider)
  end

  test "should get show" do
    service = FactoryBot.create(:simple_service, account: @provider)
    stub_backend_service_errors(service)

    xhr :get, :show, service_id: service
    assert_response :success
  end
end
