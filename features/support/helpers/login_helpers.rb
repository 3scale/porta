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

  def current_account
    current_user.account
  end
end

World(LoginHelpers)
