require 'test_helper'

class Provider::Admin::Dashboard::PotentialUpgradesControllerTest < ActionController::TestCase
  setup do
    @provider = FactoryBot.create(:provider_account)
    login_provider(@provider)
  end

  test "should get show" do
    xhr :get, :show
    assert_response :success
  end

end
