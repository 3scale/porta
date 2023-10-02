# frozen_string_literal: true

module LoginHelpers
  attr_reader :current_user

  def try_buyer_login(username, password)
    visit login_path
    fill_in('Username or Email', with: username)
    fill_in('Password', with: password)
    click_button('Sign in')

    @current_user = User.find_by!(username: username)
  end

  def try_provider_login(username, password)
    visit provider_login_path
    fill_in('Email or Username', with: username)
    fill_in('Password', with: password)
    click_button('Sign in')

    @current_user = User.find_by!(username: username)
  end

  def try_login_with_sso
    # it works for Oauth2, which is for what is being used. In case it wants to be used to Auth0, it needs the state param
    visit "/auth/#{@authentication_provider.system_name}/callback"
    @current_user = Account.last.users.last
  end

  def current_account
    current_user.account
  end
end

World(LoginHelpers)
