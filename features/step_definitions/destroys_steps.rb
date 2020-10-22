# frozen_string_literal: true

Then "I should see {string} in the list of deleted {string}" do |name, kind|
  should have_css('h1,h2,h3', text: "Deleted #{kind.capitalize}")
  should have_content(name)
end

When "provider {string} has deleted the buyer {string}" do |provider_domain, buyer_name|
  provider = Account.find_by!(domain: provider_domain)
  buyer    = FactoryBot.create(:buyer_account, provider_account: provider, org_name: buyer_name, state: :created)
  buyer.destroy
end

When "provider {string} deleted existing {buyer}" do |provider_domain, buyer|
  Account.find_by!(domain: provider_domain)
  buyer.destroy
end
