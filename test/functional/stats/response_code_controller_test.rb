require "test_helper"

class Stats::ResponseCodesControllerTest < ActionController::TestCase

  setup do
    @provider = FactoryBot.create(:provider_account)
    login_provider @provider

    @service = @provider.default_service
  end

  test "assigns service" do
    get :show, service_id: @service.id
    assert_equal @service, assigns(:service)
  end
end
