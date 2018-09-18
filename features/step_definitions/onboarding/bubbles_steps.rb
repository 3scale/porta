Given(/^a provider is logged in with onboarding process active$/) do
  step 'a provider "foo.example.com"'
  step 'current domain is the admin domain of provider "foo.example.com"'
  step 'has onboarding process active'
  step 'I log in as provider "foo.example.com"'

  @provider = Account.find_by_domain!('foo.example.com')
end

And(/^has onboarding process active/) do
  @provider.create_onboarding
end

When(/^visits the service page$/) do
  visit(admin_services_path)
end

Then(/^(.*) bubble should be visible$/) do |bubble_name|
  page.should have_selector("#onboarding-bubble-#{bubble_name}")
end
