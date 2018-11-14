helper = Module.new do
  def current_account
    current_user.account
  end

  def current_user
    # HACK: I can't access session variables easily, but there are other ways how to get what I want :)
    begin
      # provider side
      username = find(:css, '#user_widget .username').text(:all).strip
    rescue Capybara::ElementNotFound
      # buyer side
      username = find('#sign-out-button')[:title].gsub('Sign Out','').strip
    end

    assert username, "could not find username in the ui"

    current_domain = URI.parse(current_url).host
    site_account   = Account.find_by_domain(current_domain)
    site_account ||= (p = Account.find_by_self_domain!(current_domain)) && p.provider_account

    site_account.buyer_users.find_by_username!(username)
  end
end

World(helper)
