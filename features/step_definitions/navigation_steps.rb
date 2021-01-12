# frozen_string_literal: true

When "I navigate to the sent invitations page" do
  click_link "Account"
  click_link "Users"
  click_link "Sent invitations"
end

When "I navigate to the page of the partner {string}" do |partner|
  step 'I navigate to the accounts page'
  click_link partner
end

When 'I navigate to the accounts page' do
  click_link href: admin_buyers_accounts_path
end

When "I navigate to a topic in the forum of {forum}" do |forum|
  visit forum_path
  click_link forum.topics.first.title
end

When "I navigate to the forum admin page" do
  click_link 'Messages'
  click_link 'Forum'
  click_link 'Threads'
end

When "I navigate to the forum categories admin page" do
  step "I navigate to the forum admin page"
  click_link "Categories"
end

When "I navigate to the forum my posts admin page" do
  step "I navigate to the forum admin page"
  click_link "My Threads"
end

When "I navigate to my account edition page" do
  click_link "Settings"
  click_link "Edit"
end

When "I navigate to the dashboard" do
  click_link "Dashboard"
end

When "I navigate to the plans admin page" do
  click_link "Dashboard"
  click_link "API"
  click_link "Plans"
end

When "I navigate to the plans page" do
  click_link "Account"
  click_link "Plans"
end

When "I navigate to the API dashboard" do
  click_link "Dashboard"
  click_link "API"
end

When "I navigate to the application {string} of the partner {string}" do |app, partner|
  step %(I navigate to the page of the partner "#{partner}")
  step %(I follow the link to application "#{app}" in the applications widget)
end

When "I navigate to the default application of the provider" do
  provider = Account.providers.first!
  app = provider.bought_cinstances.first!
  step "I navigate to the application \"#{app.name}\" of the provider \"#{provider.domain}\""
end

When "I navigate to the application {string} of the provider {string}" do |app, partner|
  step %(I navigate to the page of the partner "#{partner}")
  step 'I go to the applications admin page'
  step %(I follow the link to application "#{app}")
end

When "I navigate to the buyers service contracts page" do
  step 'I navigate to the accounts page'
  click_link 'Subscriptions'
end

When "I navigate to the Account Settings" do
  find('#api_selector').click
  step %(I follow "Account Settings")
end
