require 'test_helper'

class DeveloperPortal::InvitationSignupTest < ActionDispatch::IntegrationTest
  include System::UrlHelpers.cms_url_helpers

  OAuth2 = Authentication::Strategy::OAuth2

  def setup
    @provider   = FactoryBot.create(:simple_provider)
    @buyer      = FactoryBot.create(:simple_buyer, provider_account: @provider)
    @invitation = FactoryBot.create(:invitation, account: @buyer)
    @auth_provider = FactoryBot.create(:authentication_provider, account: @provider)

    host! @provider.internal_domain
  end

  def test_show
    # sso attributes do not exist, sso authorization object should not be built
    # and therefore, user password should be required
    get invitee_signup_path(invitation_token: @invitation.token)
    assert_response :success
    assert assigns(:user).validate_password?

    # sso attributes do exist, sso authorization object should be built
    # and therefore, user password should not be required
    OAuth2.any_instance.stubs(:authentication_provider).returns(@auth_provider)
    OAuth2.any_instance.expects(:user_data).returns({ uid: '12345' })
    get "/auth/invitations/#{@invitation.token}/github/callback"
    assert_response :success
    get invitee_signup_path(invitation_token: @invitation.token)
    assert_response :success
    refute assigns(:user).validate_password?
    sso_authorization = assigns(:user).sso_authorizations.first
    assert_equal '12345', sso_authorization.uid
    assert_equal @auth_provider.id, sso_authorization.authentication_provider_id
  end

  def test_request_formats
    get invitee_signup_path(invitation_token: @invitation.token, format: :html)
    assert_response :success

    get invitee_signup_path(invitation_token: @invitation.token, format: :xml)
    assert_response :not_acceptable
  end

  def test_builtin_page
    get invitee_signup_path(invitation_token: @invitation.token)
    assert_match 'Invitation sign in', response.body
    assert_not_match 'Custom title', response.body

    root = FactoryBot.create(:root_cms_section, provider: @provider)
    FactoryBot.create(:cms_builtin_page,
      provider:    @provider,
      section:     root,
      system_name: 'accounts/invitee_signups/show',
      published:   'Custom title'
    )

    get invitee_signup_path(invitation_token: @invitation.token)
    assert_not_match 'Invitation sign in', response.body
    assert_match 'Custom title', response.body
  end

  def test_auth0_sso_create
    user = FactoryBot.create(:simple_user, account: @buyer)
    OAuth2.any_instance.expects(:authenticate).returns(user).at_least_once
    get "/auth/invitations/auth0/auth0_ab1234/callback?state=#{@invitation.token}"
    assert_response :redirect
    assert_equal 'Signed up successfully', flash[:notice]
  end

  def test_sso_create
    OAuth2.any_instance.stubs(:authentication_provider).returns(@auth_provider)
    OAuth2.any_instance.expects(:authenticate).returns(false).at_least_once
    get "/auth/invitations/#{@invitation.token}/github/callback"
    assert_response :success
    assert session[:invitation_sso_uid].blank?
    refute assigns(:user).valid?

    OAuth2.any_instance.expects(:user_data).returns({ uid: '12345' })
    get "/auth/invitations/#{@invitation.token}/github/callback"
    assert_response :success
    assert_equal '12345', session[:invitation_sso_uid]
    refute assigns(:user).valid?

    user = FactoryBot.create(:simple_user, account: @buyer)
    OAuth2.any_instance.expects(:authenticate).returns(user).at_least_once
    get "/auth/invitations/#{@invitation.token}/github/callback"
    assert_response :redirect
    assert_equal 'Signed up successfully', flash[:notice]
  end

  def test_error_sso_create
    OAuth2.any_instance.stubs(:authentication_provider).returns(@auth_provider)
    OAuth2.any_instance.expects(:authenticate).returns(false).at_least_once
    error_data = ThreeScale::OAuth2::ErrorData.new(error: 'The code is incorrect or expired.')
    OAuth2.any_instance.expects(:user_data).returns(error_data)

    get "/auth/invitations/#{@invitation.token}/github/callback"
    assert_response :success
    refute assigns(:user).valid?
    assert_equal 'The code is incorrect or expired.', flash[:error]
  end

  def test_create
    OAuth2.any_instance.stubs(:authentication_provider).returns(@auth_provider)

    assert_difference '@buyer.users.count' do
      post invitee_signup_path(invitation_token: @invitation.token, user: user_valid_params)
      assert_response :redirect
      assert_empty @buyer.users.reload.last.sso_authorizations
    end

    client = mock('client')
    user_data = ThreeScale::OAuth2::UserData.new(uid: 'alaska')
    client.stubs(authenticate!: user_data)
    ThreeScale::OAuth2::Client.expects(:build).with(@auth_provider).returns(client)
    @invitation.update_column(:accepted_at, nil)
    get "/auth/invitations/#{@invitation.token}/#{@auth_provider.system_name}/callback"

    assert_difference '@buyer.users.count', +1 do
      post invitee_signup_path(invitation_token: @invitation.token, user: user_valid_params)
      assert_response :redirect
      assert_not_empty authorizations = @buyer.users.reload.order(:id).last.sso_authorizations
      assert_equal ['alaska'], authorizations.pluck(:uid)
    end
  end

  private

  def user_valid_params
    index = User.maximum(:id)

    {
      email:    "foo_#{index}@example.net",
      username: "bar#{index}",
      password: 'superSecret1234#'
    }
  end
end
