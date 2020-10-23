# frozen_string_literal: true

helper = Module.new do
  def current_account
    current_user.account
  end

  def current_user
    # HACK: I can't access session variables easily, but there are other ways how to get what I want :)
    begin
      # provider side
      username = find(:css, '#user_widget .username', visible: :all).text(:all).strip
    rescue Capybara::ElementNotFound
      # buyer side
      username = find('#sign-out-button')[:title].gsub('Sign Out','').strip
    end

    assert username, "could not find username in the ui"

    site_account!.buyer_users.find_by!(username: username)
  end

  def site_account!
    current_domain = URI.parse(current_url).host
    if (site_account = Account.find_by(domain: current_domain))
      site_account
    else
      provider = Account.find_by!(self_domain: current_domain)
      provider.provider_account
    end
  end
end

World(helper)
