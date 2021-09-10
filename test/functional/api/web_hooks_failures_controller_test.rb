require 'test_helper'

class Admin::Api::WebHooksFailuresControllerTest < ActionController::TestCase

  def setup
    @provider = FactoryBot.create(:provider_account)
    @token = FactoryBot.create(:access_token, owner: @provider.admin_users.first!, scopes: %w[account_management]).value
    host! @provider.self_domain
  end

  # regression test https://github.com/3scale/system/issues/3046
  test '#destroy should rescue_form ArgumentError' do
    Settings::Switch.any_instance.stubs(:allowed?).returns(true)

    delete :destroy, time: '323123122', access_token: @token
    assert_response 400
  end

  test '#destroy without the permission' do
    Settings::Switch.any_instance.stubs(:allowed?).returns(false)

    delete :destroy, time: '323123122', access_token: @token
    assert_response :forbidden
  end
end
