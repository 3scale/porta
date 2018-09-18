Then /^I should see "(.*?)" in the list of deleted "(.*?)"$/ do | name, kind |
  should have_css('h1,h2,h3', text: "Deleted #{kind.capitalize}")
  should have_content(name)
end

When /^provider "(.*?)" has deleted the buyer "(.*?)"$/ do | provider_domain,  buyer_name |
  provider = Account.find_by_domain! provider_domain
  buyer    = Factory(:buyer_account, :provider_account => provider, :org_name => buyer_name, :state => :created)
  buyer.destroy
end

When /^provider "(.*?)" deleted existing buyer "(.*?)"$/ do | provider_domain, buyer_name|
  provider = Account.find_by_domain! provider_domain
  buyer    = Account.buyers.where(org_name: buyer_name).first!
  buyer.destroy
end
