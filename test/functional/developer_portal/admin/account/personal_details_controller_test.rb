require 'test_helper'

class DeveloperPortal::Admin::Account::PersonalDetailsControllerTest < DeveloperPortal::ActionController::TestCase

  def setup
    super
    @provider = Factory(:provider_account)
  end

  test 'no access granted for provider admin' do
    # now exists other routes in provider side

    @request.host = @provider.admin_domain

    login_as @provider.admins.first
    get :show

    assert_response 404
  end

  test 'no access granted for provider members' do
    # now exists other routes in provider side
    @request.host = @provider.admin_domain

    provider_member = Factory :active_user, :account => @provider
    assert provider_member.member?

    login_as provider_member
    get :show

    assert_response 404
  end

  context 'buyer' do
    setup do
      @request.host = @provider.domain
      @buyer = Factory :buyer_account, :provider_account => @provider
    end

    should 'grant access to admin' do
      login_as @buyer.admins.first
      get :show

      assert_response :success
    end

    should 'grant access to member' do
      buyer_member = Factory :active_user, :account => @buyer
      assert buyer_member.member?

      login_as buyer_member
      get :show

      assert_response :success
    end
  end

end
