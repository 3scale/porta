# frozen_string_literal: true

module LoginHelpers
  def try_buyer_login(username, password)
    visit login_path
    fill_in('Username or Email', with: username)
    fill_in('Password', with: password)
    click_button('Sign in')
  end

  def try_provider_login(username, password)
    visit provider_login_path
    fill_in('Email or Username', with: username)
    fill_in('Password', with: password)
    click_button('Sign in')
  end
end

World(LoginHelpers)
