require 'test_helper'

class DeveloperPortal::Admin::Applications::AccessDetailsControllerTest < DeveloperPortal::ActionController::TestCase

  # regression test for https://github.com/3scale/system/pull/2565
  test 'return the real amount of reference_filters' do
    buyer = Factory(:buyer_account)
    provider = buyer.provider_account
    Factory(:application_contract, user_account: buyer)
    host! provider.domain
    login_as(buyer.admins.first)

    get :show

    assert_not_nil cinstance = assigns(:cinstance)
    assert_equal cinstance.referrer_filters.size, cinstance.referrer_filters.count
  end

end
