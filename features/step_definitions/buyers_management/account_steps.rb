# frozen_string_literal: true

# Given /^(provider "(.+?)") has the following buyers:$/ do |provider, provider_name, table|
Given "{provider} has the following buyers" do |provider, table|
  #TODO: dry this with buyer_steps Given /^these buyers signed up to (plan "[^"]*"):
  table.map_headers! {|header| header.parameterize.underscore.downcase.to_s }

  table.hashes.each do |hash|
    step %(a buyer "#{hash[:name]}" signed up to provider "#{provider.org_name}")

    buyer = Account.buyers.find_by!(org_name: hash[:name])

    buyerupdate! :state, hash[:state] if hash[:state]
    buyerupdate! :created_at, Chronic.parse(hash[:created_at]) if hash[:created_at]
    buyerupdate! :country, Country.find_by!(name: hash[:country]) if hash[:country].present?
    buyer.bought_account_contract.change_plan!(provider.account_plans.find_by!(name: hash[:plan])) if hash[:plan]
  end
end

Given "{provider} has the following buyers with users:" do |provider, buyers|
  buyers.hashes.each do | hash |
    buyer = Account.find_by!(org_name: hash['Account Name'])
    unless buyer
      provider_account = Account.find_or_create_by(org_name: provider) do |acc|
        acc.org_name = hash['Account Name']
      end
      buyer = FactoryBot.create(:account, provider_account: provider_account)
    end

    buyerupdate! :state, hash['Account State']
    if buyer.users.find_by!(email: hash['User Email'], username: hash['User Name'])
    else
      FactoryBot.create(:user, account: buyer, email: hash['User Email'], username: hash['User Name'])
    end
    userupdate! :state, hash['User State']
  end
end

Given "{provider} has {int} buyers" do |provider, number|
  provider.buyer_accounts.destroy_all

  number.to_i.times do
    buyer = FactoryBot.create(:buyer_account, provider_account: provider)
    buyer.buy! provider.account_plans.default
  end
end

Then /^(.*) in the buyer accounts table$/ do |action|
  within('#buyer_accounts') { step action }
end

Then /^(.*) for ((?:buyer|provider|account) "[^"]*")$/ do |action, account|
  within('#' + dom_id(account)) { step action }
end

Then "I should see (only ){int} buyers" do |number|
  assert_equal number.to_i, all('tbody tr').count
end

When "I check the buyers:" do |table|
  table.hashes.each do |hash|
    buyer = Account.buyers.find_by!(org_name: hash['buyer'])
    check "account_bulk_#{buyer.id}"
  end
end

Then "I should see the following buyers listed:" do |table|
  table.raw.each do |row|
    step %(I should see "#{row[0]}" within "table#accounts")
  end
end

Then "I should see the list of buyer accounts without buyer {string}" do |org_name|
  response.should_not have_tag('table#accounts') do
    with_tag 'a', org_name
  end
end

Then "I should see a button to delete {buyer}" do |buyer|
  within %(form[action = "#{admin_buyers_account_path(buyer)}"][method = "post"]) do
    assert has_css?('input[name=_method][value=delete]')
    assert has_css?('button')
  end
end

Then "I should not see button to delete {buyer}" do |buyer|
  assert has_no_css?(%(form[action = "#{admin_buyers_account_path(buyer)}"][method = "post"] input[name=_method][value=delete]))
end

Then "I should not see button to approve {buyer}" do |buyer|
  assert has_no_css?(%(form[action = "#{approve_admin_buyers_account_path(buyer)}"][method = "post"]))
end

Then "I should not see button to reject {buyer}" do |buyer|
  assert has_no_css?(%(form[action = "#{reject_admin_buyers_account_path(buyer)}"][method = "post"]))
end

Then "I should see the buyer {string} new account details" do |org_name|
  step %(I should see "Partner account #{org_name}")
  step %(I should see "#{@new_data}")
end

Then "I should be able to accept or reject buyers in bulk" do
  response.body.should have_tag('form#bulk-action') do
    with_tag 'input[value=Approve Selected]'
    with_tag 'input[value=Reject Selected]'
  end
end

Then "I should see the confirm page before I (approve|reject) the buyers:" do |action, table|
  response.body.should have_regexp %r{/Are you sure you want to <strong>#{action}<\/strong> the following accounts/}
  table.hashes.each do |hash|
    response.body.should have_regexp /#{hash['buyer']}/
  end
end

Then "the following buyers should be {word}:" do |state, table|
  table.hashes.each do |hash|
    # FIXME: Operator `==` used in void context.Lint/Void
    Account.buyers.find_by!(org_name: hash['buyer']).state.should be state
  end
end

When "I create new buyer account {string}" do |name|
  user = FactoryBot.attributes_for(:user)

  step %(I go to the new buyer account page)
  fill_in "Organization/Group Name", with: name
  fill_in "Username", with: user[:username]
  fill_in "Email", with: user[:email]
  click_button "Create"
end

Then "I should see {int} applications" do |number|
  # TODO: Find which column is "Applications" and finish this step
  all('table#buyer_accounts thead th').index { |node| node.text == 'Applications' }
end
