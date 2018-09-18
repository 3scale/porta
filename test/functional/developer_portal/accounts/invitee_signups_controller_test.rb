require 'test_helper'

class DeveloperPortal::Accounts::InviteeSignupsControllerTest < DeveloperPortal::ActionController::TestCase

  def setup
    super
    @provider     = FactoryGirl.create(:provider_account)
    @request.host = @provider.domain
  end

  test 'should redirect out logged in users' do
    login_as(@provider.admins.first)

    get :show, invitation_token: 'abc123'

    assert_redirected_to '/admin'
  end

  test 'should show invitation not found message' do
    get :show, invitation_token: 'INVALID'

    assert_response :redirect

    assert flash[:error], I18n.t('errors.messages.invitation_not_found')
  end

  test 'invitation belongs to a different provider' do
    new_provider = FactoryGirl.create(:provider_account)
    invitation   = FactoryGirl.create(:invitation, account: new_provider)

    get :show, invitation_token: invitation.token

    assert_response :redirect

    assert flash[:error], I18n.t('errors.messages.invitation_not_found')
  end

  test 'user successfully activated' do
    buyer      = FactoryGirl.create(:buyer_account, provider_account: @provider)
    invitation = FactoryGirl.create(:invitation, account: buyer)

    assert_difference(buyer.users.method(:count), +1) do
      get :create, invitation_token: invitation.token,
        user: { username: 'johndoe123', password: 'heslo123' }
    end

    assert_response :redirect

    assert flash[:notice], I18n.t('flash.signups.create.notice')
  end

  test 'push webhook' do
    WebHook::Event.expects(:enqueue).times(1)

    buyer      = FactoryGirl.create(:buyer_account, provider_account: @provider)
    invitation = FactoryGirl.create(:invitation, account: buyer)

    get :create, invitation_token: invitation.token,
      user: { username: 'johndoe123', password: 'heslo123' }
  end
end
