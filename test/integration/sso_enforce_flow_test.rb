require 'test_helper'

class SsoEnforceFlowTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryGirl.create(:provider_account)
    @user = FactoryGirl.create(:simple_admin, account: @provider, password: 'alaska1233')
    @user.activate!

    host! @provider.admin_domain
  end

  def test_sso_enforce
    # password signup form is visible
    get new_provider_sessions_path
    assert_response :success
    assert_match 'Email or Username', response.body

    # username & password login
    post provider_sessions_path(username: @user.username, password: 'alaska1233')
    assert_match 'Signed in successfully', flash[:notice]
    refute_nil User.current

    # there's no auth providers, no enforce sso info error message yet
    get provider_admin_account_authentication_providers_path
    assert_response :success
    refute_match enforce_error_message, response.body

    # new auth provider has been created, not published yet
    get new_provider_admin_account_authentication_provider_path
    assert_response :success
    assert_equal 0, @provider.self_authentication_providers.count
    Timecop.freeze(0.5.hour.ago) do
      post provider_admin_account_authentication_providers_path(authentication_provider: { client_id: '1',
      client_secret: '2', site: 'http://alaska.eu.auth0.com', kind: 'auth0' })
      assert_response :redirect
      assert_equal 'SSO integration created', flash[:notice]
    end
    auth_provider = @provider.reload.self_authentication_providers.first
    assert auth_provider

    # there's one auth provider, enforce sso info error message is visible
    get provider_admin_account_authentication_providers_path
    assert_response :success
    assert_match enforce_error_message, response.body

    # auth provider has not been tested yet, error message visible
    get provider_admin_account_authentication_provider_path(auth_provider)
    assert_response :success
    assert_match needs_to_be_testet_error, response.body

    # auth provider tested with not verified email address
    stub_request(:post, 'http://alaska.eu.auth0.com/oauth/token').to_return(status: 200)
    user_attributes = { email: @user.email, uid: 'bar|123', authentication_id: 'alaska' }
    user_data = ThreeScale::OAuth2::UserData.new(user_attributes)
    ThreeScale::OAuth2::Auth0Client.any_instance.expects(:authenticate!).returns(user_data).at_least_once
    get provider_admin_account_flow_testing_callback_url(system_name: auth_provider.system_name)
    assert_match 'User cannot be authenticated by not verified email address.', flash[:error]

    # auth provider successfully tested
    stub_request(:post, 'http://alaska.eu.auth0.com/oauth/token').to_return(status: 200)
    user_attributes = { email: @user.email, email_verified: true, uid: 'bar|123', authentication_id: 'alaska' }
    user_data = ThreeScale::OAuth2::UserData.new(user_attributes)
    ThreeScale::OAuth2::Auth0Client.any_instance.expects(:authenticate!).returns(user_data).at_least_once
    get provider_admin_account_flow_testing_callback_url(system_name: auth_provider.system_name)
    assert_match 'Authentication flow successfully tested.', flash[:success]

    # auth provider has been tested, no error message visible
    get provider_admin_account_authentication_provider_path(auth_provider)
    assert_response :success
    refute_match needs_to_be_testet_error, response.body

    # auth provider successfully published
    refute auth_provider.published?
    post provider_admin_account_authentication_provider_publishing_path(auth_provider)
    assert_match 'SSO Integration successfully published', flash[:notice]
    assert auth_provider.reload.published?

    # current user is not sso logged in
    get provider_admin_account_authentication_providers_path
    assert_response :success
    assert_match enforce_error_message, response.body

    # current user logs out
    delete provider_sessions_path
    assert_response :redirect
    assert_match 'You have been logged out.', flash[:notice]

    # current user has been sso logged in
    get provider_sso_path(system_name: auth_provider.system_name)
    assert_match 'Signed in successfully', flash[:notice]

    # there's no enforce sso info error message
    get provider_admin_account_authentication_providers_path
    assert_response :success
    refute_match enforce_error_message, response.body

    # enforce sso feature has been successfully enabled
    refute @provider.settings.enforce_sso?
    post provider_admin_account_enforce_sso_path
    assert_match 'SSO successfully enforced', flash[:notice]
    assert @provider.reload.settings.enforce_sso?

    # current user logs out
    delete provider_sessions_path
    assert_response :redirect
    assert_match 'You have been logged out.', flash[:notice]

    # password login is disabled, there's no passoword login form
    get new_provider_sessions_path
    assert_response :success
    refute_match 'Email or Username', response.body

    # password login is disabled
    post provider_sessions_path(username: @user.username, password: 'alaska1233')
    refute_match 'Signed in successfully', flash[:notice]
    assert_response :success
    assert_nil User.current

    # current user has been sso logged in
    get provider_sso_path(system_name: auth_provider.system_name)
    assert_match 'Signed in successfully', flash[:notice]
  end

  private

  def needs_to_be_testet_error
    'The SSO Integration needs to be tested'
  end

  def enforce_error_message
    'In order to be able to enforce SSO, at least 1 SSO Integration ' \
    'needs to be published, all published SSO Integrations need to have ' \
    'been tested within the last hour and you need to be signed in through SSO yourself.'
  end
end
