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
    host! account.admin_domain
    login_as user
  end

  def login_buyer(account, user: account.admins.first!)
    host! account.provider_account.domain
    login_as user
  end
end

ActionDispatch::IntegrationTest.class_eval do
  private

  def login!(provider, user: provider.admins.first)
    host! provider.self_domain
    provider_login_with user.username, 'supersecret'
  end

  alias_method :login_provider, :login!

  def login_buyer(account)
    host! account.provider_account.domain
    user = account.admins.first
    login_with user.username, 'supersecret'
  end

  def provider_login_with(username, password)
    get '/p/login'
    follow_redirect! while redirect?
    post provider_sessions_path, params: {username: username, password: password}
    follow_redirect! while redirect?
  end

  def login_with(username, password)
    get '/login'
    follow_redirect! while redirect?
    post '/session', params: {username: username, password: password}
    follow_redirect! while redirect?
  end

  def logout!
    get '/p/logout'
  end
end
