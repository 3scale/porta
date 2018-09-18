require 'test_helper'

class Api::EndUserPlansControllerTest < ActionController::TestCase

  test "should lookup correct API Service while editing" do
    provider = Factory(:provider_account)
    provider.settings.allow_end_users!

    service = provider.first_service!
    service_two = provider.services.create :name => "Second"
    end_user_plan = Factory(:end_user_plan, :service => service_two)

    @request.host = provider.domain
    login_as(provider.admins.first)

    @controller.stubs(:render)
    get :edit, id: end_user_plan
    assert_response :success
    assert_equal service_two, assigns(:service)
  end

end
