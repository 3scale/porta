# frozen_string_literal: true

module SiteAccount

  # finding the site account
  def site_account
    Account.providers.find_by(domain: @domain)
  end

end
