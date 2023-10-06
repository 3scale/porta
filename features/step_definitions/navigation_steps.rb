# frozen_string_literal: true

When /^I navigate to the page of the partner "([^\"]*)"$/ do |partner|
  step 'I navigate to the accounts page'
  click_link partner
end

When 'I navigate to the accounts page' do
  click_link href: admin_buyers_accounts_path
end

# TODO: THREESCALE-8033 Remove this step as it's no longer in use.
When "I navigate to a topic in the forum of {forum}" do |forum|
  visit forum_path
  click_link forum.topics.first.title
end

When "I should not see forum" do
  visit forum_path
  step 'I should see "Page not found"'
end

When /^I navigate to the forum admin page$/ do
  click_link 'Messages'
  click_link 'Forum'
  click_link 'Threads'
end

When /^I navigate to the forum categories admin page$/ do
  step "I navigate to the forum admin page"
  click_link "Categories"
end

When /^I navigate to the forum my posts admin page$/ do
  step "I navigate to the forum admin page"
  click_link "My Threads"
end

When "I navigate to the {application} of the partner {string}" do |app, partner|
  step %(I navigate to the page of the partner "#{partner}")
  within '#applications_widget' do
    find(:xpath, "//a[@href='#{provider_admin_application_path(app)}']").click
  end
end

When "they are reviewing the provider's application details" do
  provider = Account.providers.first!
  app = provider.bought_cinstances.first!
  step %(I navigate to the page of the partner "#{provider.org_name}")
  step 'I go to the applications admin page'
  find(:xpath, "//a[@href='#{provider_admin_application_path(app)}']").click
end

When "I navigate to the Account Settings" do
  select_context 'Account Settings'
end

private

def context_selector
  @context_selector ||= find('[data-ouia-component-id="context-selector"]')
end

def select_context(context)
  context_selector.click
  within(context_selector) do
    click_link context
  end
end
