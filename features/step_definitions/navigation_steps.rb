# frozen_string_literal: true

When /^I navigate to the page of the partner "([^\"]*)"$/ do |partner|
  click_link(href: admin_buyers_accounts_path)
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
  assert_text "Page not found"
end

When "I navigate to the {application} of the partner {string}" do |app, partner|
  click_link(href: admin_buyers_accounts_path)
  click_link partner
  within '#applications_widget' do
    find(:xpath, "//a[@href='#{provider_admin_application_path(app)}']").click
  end
end

When "they are reviewing the provider's application details" do
  provider = Account.providers.first!
  app = provider.bought_cinstances.first!
  click_link(href: admin_buyers_accounts_path)
  click_link provider.org_name
  visit provider_admin_applications_path
  find(:xpath, "//a[@href='#{provider_admin_application_path(app)}']").click
end

When "I navigate to the Account Settings" do
  select_context 'Account Settings'
end

When "they select {string} from the context selector" do |context|
  select_context context
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
