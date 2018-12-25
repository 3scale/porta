require 'test_helper'

class Admin::Api::WebHooksFailuresControllerTest < ActionController::TestCase

  def setup
    @provider = FactoryBot.create(:provider_account)

    host! @provider.self_domain
    login_as(@provider.admins.first)
  end

  # regression test https://github.com/3scale/system/issues/3046
  test '#destroy should rescue_form ArgumentError' do
    Settings::Switch.any_instance.stubs(:allowed?).returns(true)

    delete :destroy, time: '323123122'
    assert_response 400
  end

  test '#destroy without the permission' do
    Settings::Switch.any_instance.stubs(:allowed?).returns(false)

    delete :destroy, time: '323123122'
    assert_response :forbidden
  end
end
