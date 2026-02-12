require 'test_helper'

class SsoEnforceFlowTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:provider_account)
    @user = FactoryBot.create(:simple_admin, account: @provider, password: 'superSecret1234#')
    @user.activate!

    host! @provider.external_admin_domain
  end

  def test_sso_enforce # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    # password signup form is visible
    get new_provider_sessions_path
    assert_response :success
    assert_match 'id="pf-login-page-container', response.body

    # username & password login
    post provider_sessions_path(username: @user.username, password: 'superSecret1234#')
    assert_match 'Signed in successfully', flash[:success]
    assert_not_nil User.current

    # new auth provider has been created, not published yet
    get new_provider_admin_account_authentication_provider_path
    assert_response :success
    assert_equal 0, @provider.self_authentication_providers.count
    travel_to(0.5.hour.ago) do
      post provider_admin_account_authentication_providers_path(authentication_provider: { client_id: '1',
      client_secret: '2', site: 'http://alaska.eu.auth0.com', kind: 'auth0' })
      assert_response :redirect
      assert_equal 'SSO integration created', flash[:success]
    end
    auth_provider = @provider.reload.self_authentication_providers.first
    assert auth_provider

    # auth provider has not been tested yet, error message visible
    get provider_admin_account_authentication_provider_path(auth_provider)
    assert_response :success
    assert_match needs_to_be_testet_error, response.body

    # auth provider tested with not verified email address
    stub_request(:post, 'http://alaska.eu.auth0.com/oauth/token').to_return(status: 200)
    user_attributes = { email: @user.email, uid: 'bar|123', authentication_id: 'alaska' }
    user_data = ThreeScale::OAuth2::UserData.new(user_attributes)
    ThreeScale::OAuth2::Auth0Client.any_instance.expects(:authenticate!).returns(user_data).at_least_once
    get provider_admin_account_flow_testing_callback_url(system_name: auth_provider.system_name, code: 'foo')
    assert_match 'User cannot be authenticated by not verified email address.', flash[:danger]

    # auth provider successfully tested
    stub_request(:post, 'http://alaska.eu.auth0.com/oauth/token').to_return(status: 200)
    user_attributes = { email: @user.email, email_verified: true, uid: 'bar|123', authentication_id: 'alaska' }
    user_data = ThreeScale::OAuth2::UserData.new(user_attributes)
    ThreeScale::OAuth2::Auth0Client.any_instance.expects(:authenticate!).returns(user_data).at_least_once
    get provider_admin_account_flow_testing_callback_url(system_name: auth_provider.system_name, code: 'foo')
    assert_match 'Authentication flow successfully tested', flash[:success]

    # auth provider has been tested, no error message visible
    get provider_admin_account_authentication_provider_path(auth_provider)
    assert_response :success
    assert_no_match needs_to_be_testet_error, response.body

    # auth provider successfully published
    assert_not auth_provider.published?
    post provider_admin_account_authentication_provider_publishing_path(auth_provider)
    assert_match 'SSO Integration successfully published', flash[:success]
    assert auth_provider.reload.published?

    # current user logs out
    delete provider_sessions_path
    assert_response :redirect
    assert_match 'You have been logged out', flash[:info]

    # current user has been sso logged in
    get provider_sso_path(system_name: auth_provider.system_name, code: 'foo')
    assert_match 'Signed in successfully', flash[:success]

    # enforce sso feature has been successfully enabled
    @provider.settings.update!(enforce_sso: true)

    # current user logs out
    delete provider_sessions_path
    assert_response :redirect
    assert_match 'You have been logged out', flash[:info]

    # password login is disabled
    post provider_sessions_path(username: @user.username, password: 'alaska1233')
    assert_no_match 'Signed in successfully', flash[:success]
    assert_response :success
    assert_nil User.current

    # current user has been sso logged in
    get provider_sso_path(system_name: auth_provider.system_name, code: 'foo')
    assert_match 'Signed in successfully', flash[:success]
  end

  private

  def needs_to_be_testet_error
    'The SSO Integration needs to be tested'
  end
end
