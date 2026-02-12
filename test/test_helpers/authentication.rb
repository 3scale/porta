ActiveSupport::TestCase.class_eval do

  private

  def mock_oauth2(authentication_id, code, user_info_url, identifier_key = 'id')
    get_object = mock('get object')
    get_object.expects(:parsed).returns({identifier_key => authentication_id})
    access_token = mock('access token')
    access_token.expects(:token).at_least_once.returns('fake-token')
    access_token.stubs(:params).returns({'id_token' => 'fake-id_token'})
    access_token.expects(:get).with(user_info_url).returns(get_object)
    OAuth2::Strategy::AuthCode.any_instance.expects(:get_token).with(code, {}).returns(access_token)
  end
end

ActionController::TestCase.class_eval do
  private

  def login_as(user)
    @controller.send(:current_user=, user)
    if user
      @controller.send(:create_user_session!)
    else
      cookies.clear
    end

    user
  end

  def login_provider(account, user: account.admins.first!)
    host! account.internal_admin_domain
    login_as user
  end

  def login_buyer(account, user: account.admins.first!)
    host! account.provider_account.internal_domain
    login_as user
  end
end

ActionDispatch::IntegrationTest.class_eval do
  private

  def login!(provider, user: provider.admins.first)
    host! provider.external_admin_domain
    provider_login_with user.username, 'superSecret1234#'
  end

  alias_method :login_provider, :login!

  def login_buyer(account)
    host! account.provider_account.internal_domain
    user = account.admins.first
    login_with user.username, 'superSecret1234#'
  end

  def provider_login_with(username, password)
    post provider_sessions_path, params: {username: username, password: password}
    follow_redirect! while redirect?
    assert_response :success
  end

  def login_with(username, password)
    post '/session', params: {username: username, password: password}
    follow_redirect! while redirect?
  end

  def logout!
    get provider_logout_path
  end

  def with_forgery_protection(enabled: true)
    ActionController::Base.any_instance.stubs(allow_forgery_protection: enabled)
    yield
  ensure
    ActionController::Base.any_instance.stubs(allow_forgery_protection: false)
  end
end
