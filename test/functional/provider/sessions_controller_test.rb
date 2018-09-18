require 'test_helper'

class Provider::SessionsControllerTest < ActionController::TestCase

  test 'logout of provider with partner and logout_url' do
    partner = FactoryGirl.create(:partner, logout_url: "http://example.net/?")
    account = FactoryGirl.create(:provider_account, partner: partner)
    host! account.self_domain

    login_as(account.first_admin)
    get :destroy
    assert_redirected_to "http://example.net/?provider_id=#{account.id}&user_id=#{account.first_admin.id}"
  end
end
