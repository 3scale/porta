# frozen_string_literal: true

Given "{application} has extra field {string} blank" do |app, attr|
  app.update!(extra_fields: { attr => nil })
end

Then "I should see a list of available plans" do |table|
  table.hashes.each do |hash|
    assert page.has_css?('li a', text: hash[:plan])
  end
end

When "I follow {string} for {application}" do |label, application|
  step %(I follow "#{label}" within "#application_#{application.id}")
end

Then "I enter my credit card details" do
  stub_braintree_authorization
  stub_successful_braintree_update

  click_on 'enter your Credit Card details'
  assert_equal admin_account_braintree_blue_path, current_path

  click_on 'Add Credit Card Details and Billing Address'
  fill_in_braintree_form

  click_on 'Save details'
end

Given "{buyer} has no live applications" do |buyer|
  buyer.bought_cinstances.map &:suspend!
end

Then "{application} should be live" do |application|
  assert application.live?
end

When /^I create an application "([^"]*)" from the audience context/ do |name|
  visit path_to "the provider's new application page"
  fill_in_new_application_form(name: name)
  click_on 'Create application'
end

When /^I create an application "([^"]*)" from the account "([^"]*)" context/ do |name, account_name|
  visit path_to %(the buyer account's new application page for "#{account_name}")
  fill_in_new_application_form(name: name)
  click_on 'Create application'
end

When /^I create an application "([^"]*)" from the product "([^"]*)" context/ do |name, service_name|
  visit path_to %(product "#{service_name}" new application page)
  fill_in_new_application_form(name: name)
  click_on 'Create application'
end

When 'I fill in the new application form' do
  fill_in_new_application_form
end

When 'I fill in the new application form for product {string}' do |service_name|
  fill_in_new_application_form(service_name: service_name)
end

When 'I fill in the new application form with extra fields:' do |table|
  fill_in_new_application_form
  table.hashes.each do |h|
    # step %(I fill in "#{hash[:field]}" with "#{hash[:value]}")
    fill_in_pf(h[:field], with: h[:value])
  end
end

When 'I should not be allowed to create more applications' do
  visit path_to "the provider's new application page"
  fill_in_new_application_form
  click_on 'Create application'
  assert has_content?('Access Denied')
end

When /^buyer "([^"]*)" should not be allowed to create more applications/ do |buyer_name|
  visit path_to %(the buyer account's new application page for "#{buyer_name}")
  fill_in_new_application_form
  click_on 'Create application'
  assert has_content?('Access Denied')
end

When /^I should not be allowed to create more applications for product "([^"]*)"/ do |service_name|
  visit path_to %(product "#{service_name}" new application page)
  fill_in_new_application_form
  click_on 'Create application'
  assert has_content?('Access Denied')
end

When "a service {string} of {provider} with no service plans" do |service_name, provider|
  service = provider.services.create!(name: service_name)
  service.service_plans.destroy_all
end

When "I won't be able to select an application plan" do
  assert app_plan_select.has_css?('.pf-m-disabled')
end

def fill_in_new_application_form(name: 'My App', service_name: 'API')
  pf4_select_first(from: 'Account') if page.has_css?('.pf-c-form__label', text: 'Account')
  pf4_select(service_name, from: 'Product') if page.has_css?('.pf-c-form__label', text: 'Product')
  pf4_select_first(from: 'Application plan') unless app_plan_select.has_css?('.pf-m-disabled')
  fill_in_pf('Name', with: name)
  fill_in_pf('Description', with: 'This is some kind of application')
end

def app_plan_select
  find_pf_select('Application plan')
end

def fill_in_pf(label, with:)
  find('.pf-c-form__group-label', text: label).sibling('.pf-c-form__group-control')
                                              .find('input')
                                              .set(with)
end
