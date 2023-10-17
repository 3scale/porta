# frozen_string_literal: true

Given "{provider} has the following buyers:" do |provider, table|
  #TODO: dry this with buyer_steps Given /^these buyers signed up to (plan "[^"]*"):
  parameterize_headers(table)

  table.hashes.each do |hash|
    buyer = FactoryBot.create(:buyer_account, provider_account: provider,
                                              org_name: hash[:name],
                                              buyer: true)

    buyer.update!(state: hash[:state]) if hash[:state]
    buyer.update!(created_at: Chronic.parse(hash[:created_at])) if hash[:created_at]
    buyer.update!(country: Country.find_by!(name: hash[:country])) if hash[:country].present?

    next unless (plan_name = hash[:plan])

    plan = provider.account_plans.find_by(name: plan_name) ||
           create_plan(:account, name: plan_name, issuer: provider)
    buyer.buy! plan
  end
end

Given "{provider} has {int} buyer(s)" do |provider, number|
  provider.buyer_accounts.destroy_all

  number.to_i.times do
    buyer = FactoryBot.create(:buyer_account, :provider_account => provider)
    buyer.buy! provider.account_plans.default
  end
end

Then /^(.*) in the buyer accounts table$/ do |action|
  within('#buyer_accounts') { step action }
end

Then /^(.*) for (?:buyer|provider|account) "([^"]*)"$/ do |action, org_name|
  account = Account.find_by!(org_name: org_name)
  within('#' + dom_id(account)) { step action }
end

Then /^I should see (?:only )?(\d+) buyers$/ do |number|
  assert_equal number.to_i, all('tbody tr').count
end

Then "I should not see button to approve {buyer}" do |buyer|
  assert has_no_css?(%(form[action = "#{approve_admin_buyers_account_path(buyer)}"][method = "post"]))
end

Then "I should not see button to reject {buyer}" do |buyer|
  assert has_no_css?(%(form[action = "#{reject_admin_buyers_account_path(buyer)}"][method = "post"]))
end

When /^I create new buyer account "([^\"]*)"$/ do |name|
  user = FactoryBot.attributes_for(:user)

  step %(I go to the new buyer account page)
  fill_in "Organization/Group Name", :with => name
  fill_in "Username", :with => user[:username]
  fill_in "Email", :with => user[:email]
  click_button "Create"
end
