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
    visit "/auth/#{@authentication_provider.system_name}/callback"
    @current_user = Account.last.users.last
  end

  def try_buyer_login_sso_token
    visit create_session_path(expires_at: @sso_token.expires_at, token: @sso_token.encrypted_token)
    @current_user = Account.last.users.last
  end

  def try_provider_login(username, password)
    visit provider_login_path
    fill_in('Email or Username', with: username)
    fill_in('Password', with: password)
    click_button('Sign in')

    @current_user = User.find_by!(username: username)
  end

  def current_account
    current_user.account
  end

  def log_out
    find(:css, '[aria-label="Session toggle"]').click
    click_link 'Sign Out'
  end
end

World(SessionHelper)
