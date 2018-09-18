module SiteAccount

  #finding the site account
  def site_account
    Account.providers.find_by_domain @domain
  end

end
