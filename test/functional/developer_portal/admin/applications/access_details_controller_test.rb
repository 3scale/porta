require 'test_helper'

class DeveloperPortal::Admin::Applications::AccessDetailsControllerTest < DeveloperPortal::ActionController::TestCase

  # regression test for https://github.com/3scale/system/pull/2565
  test 'return the real amount of reference_filters' do
    buyer = FactoryBot.create(:buyer_account)
    provider = buyer.provider_account
    FactoryBot.create(:application_contract, user_account: buyer)
    host! provider.internal_domain
    login_as(buyer.admins.first)

    get :show

    assert_not_nil cinstance = assigns(:cinstance)
    # NOTE: this assertion fails when has_many_inversing = true (Rails 6.1 default)
    assert_equal cinstance.referrer_filters.size, cinstance.referrer_filters.count
  end

end
