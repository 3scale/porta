When /^I navigate to the sent invitations page$/ do
  click_link "Account"
  click_link "Users"
  click_link "Sent invitations"
end

When /^I navigate to the page of the partner "([^\"]*)"$/ do |partner|
  click_link "Accounts"
  click_link partner
end

When 'I navigate to the accounts page' do
  click_link "Accounts"
end

When /^I navigate to a topic in (the forum of "[^\"]*")$/ do |forum|
  visit forum_path
  click_link forum.topics.first.title
end

When /^I navigate to the forum admin page$/ do
  click_link 'Messages'
  click_link 'Threads'
end

When /^I navigate to the forum categories admin page$/ do
  step "I navigate to the forum admin page"
  click_link "Categories"
end

When /^I navigate to the forum my posts admin page$/ do
  step "I navigate to the forum admin page"
  click_link "My threads"
end

When /^I navigate to my account edition page$/ do
  click_link "Settings"
  click_link "Edit"
end

When /^I navigate to the dashboard$/ do
  click_link "Dashboard"
end


When /^I navigate to the plans admin page$/ do
  click_link "Dashboard"
  click_link "API"
  click_link "Plans"
end

When /^I navigate to the plans page$/ do
  click_link "Account"
  click_link "Plans"
end

When /^I navigate to the API dashboard$/ do
  click_link "Dashboard"
  click_link "API"
end

When /^I navigate to the application "([^"]*)" of the partner "([^"]*)"$/ do |app, partner|
  step %(I navigate to the page of the partner "#{partner}")
  step %(I follow the link to application "#{app}" in the applications widget)
end

When /^I navigate to the default application of the provider$/ do
  provider = Account.providers.first!
  app = provider.bought_cinstances.first!
  step "I navigate to the application \"#{app.name}\" of the provider \"#{provider.domain}\""
end

When /^I navigate to the application "([^"]*)" of the provider "([^"]*)"$/ do |app, partner|
  step %(I navigate to the page of the partner "#{partner}")
  step 'I navigate to the buyers applications page'
  step %(I follow the link to application "#{app}")
end

When /^I navigate to the buyers applications page$/ do
  click_link 'Applications'
end

When /^I navigate to the buyers service contracts page$/ do
  click_link(:text => /\ADevelopers|Tenants\z/)
  click_link 'Subscriptions'
end
