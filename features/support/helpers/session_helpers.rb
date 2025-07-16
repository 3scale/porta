# frozen_string_literal: true

module SessionHelper
  attr_reader :current_user

  def try_buyer_login_internal(username, password)
    visit login_path
    fill_in('Username or Email', with: username)
    fill_in('Password', with: password)
    click_button('Sign in')

    @current_user = User.find_by!(username: username)
  end

  def try_buyer_login_oauth
    # it works for Oauth2, which is for what is being used. In case it wants to be used to Auth0, it needs the state param
    visit "/auth/#{@authentication_provider.system_name}/callback?code=foo"
    @current_user = Account.last.users.last
  end

  def try_buyer_login_sso_token
    visit create_session_path(expires_at: @sso_token.expires_at, token: @sso_token.encrypted_token)
    @current_user = Account.last.users.last
  end

  def try_provider_login(username, password)
    ensure_javascript
    visit provider_login_path
    fill_in('Email or Username', with: username)
    fill_in('Password', with: password)
    click_button('Sign in')
  end

  def current_account
    current_user.account
  end

  # provider log out
  def log_out
    return unless logged_in?

    find(:css, '[aria-label="Session toggle"]').click
    click_link 'Sign Out'
    assert_current_path '/p/sessions/new'
  end

  def assert_current_user(username)
    @current_user = User.find_by(username: username)

    browser = Capybara.current_session.driver.browser
    if Capybara.current_driver == :rack_test
      assert browser.current_session.cookie_jar[:user_session]
    else
      assert browser.manage.cookie_named(:user_session)
    end
  end

  def user_is_logged_in(username)
    assert_no_current_path %r{\A(/p/sessions|/session|/p/login|/login)\z}, ignore_query: true
    assert_current_user(username)
  end

  private

  def logged_in?
    has_css?('[aria-label="Session toggle"]', wait: 0)
  end
end

World(SessionHelper)
