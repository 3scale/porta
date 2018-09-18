require 'test_helper'

class Provider::InviteeSignupsControllerTest < ActionController::TestCase

  class RoutingTest < ActionController::TestCase
    def setup
      ProviderDomainConstraint.stubs(matches?: true)
      MasterDomainConstraint.stubs(matches?: true)
    end

    should route(:get, '/p/signup/token').to(action: 'show', invitation_token: 'token')
    should route(:post, '/p/signup/token').to(action: 'create', invitation_token: 'token')
  end

  def setup
    @provider = FactoryGirl.create(:simple_provider)
    host! @provider.admin_domain
    @invitation = FactoryGirl.create(:invitation, account: @provider)
  end

  def test_show
    get :show, invitation_token: @invitation.token

    assert_response :success
    assert_template 'show'
  end

  def test_create
    Logic::RollingUpdates.stubs(enabled?: true)

    assert_difference '@provider.users.count' do
      post :create, invitation_token: @invitation.token, user: { username: 'admin', password: 'supersecret' }
      assert_redirected_to provider_login_path
    end
  end

  def test_ask_for_upgrade
    @provider.create_provider_constraints!(max_users: 0)

    get :show, invitation_token: @invitation.token

    assert_response :success
    assert_template 'ask_for_upgrade'

    get :create, invitation_token: @invitation.token

    assert_response :success
    assert_template 'ask_for_upgrade'
  end
end
