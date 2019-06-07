# frozen_string_literal: true

Given(/^the provider has (\d) active docs?$/) do |number_active_docs|
  @active_docs = FactoryBot.create_list(:api_docs_service, number_active_docs.to_i, account: @provider, service: @provider.default_service)
end

When /^I try to (create|update) the active docs( of the service)? with (in)?valid data$/ do |action, optional_scope, invalid|
  action_page = action == 'update' ? 'edit' : 'new'
  scope = optional_scope.present? ? ' for a service' : ''
  step "I go to the #{action_page} active docs page#{scope}"
  fill_in('Name', with: 'ActiveDocsName')
  api_spec = invalid ? 'invalid' : FactoryBot.build(:api_docs_service).body
  # binding.pry
  # fill_in('API JSON Spec', with: api_spec)
  # find(:xpath, '//*[@id="api_docs_service_body"]', visible: true).set(api_spec)
  find(:xpath, '//*[@id="api_docs_service_body"]').set(api_spec)
  click_on "#{action.capitalize!} Service"
end

When /^I select a service from the service selector$/ do
  select(@provider.default_service.name, from: 'api_docs_service_service_id')
end

Then 'I should see the active docs errors in the page' do
  step 'I should see "JSON Spec is invalid"'
end

Then /^the table should( not)? contain the API$/ do |negate|
  step "I should#{negate} see \"API\" within the table header"
  step "I should#{negate} see \"#{@provider.default_service.name}\" within the table body"
end

Then(/^the service selector is not in the form$/) do
  refute has_xpath?('//form//select[@id="api_docs_service_service_id"]')
end

Then(/^the api doc spec is saved with this service linked$/) do
  assert_selector('.flash-message--notice', text: /ActiveDocs Spec was successfully (saved|updated)./)
end

Then(/^the swagger autocomplete should work for "(.*?)" with "(.*?)"$/) do |input_name, autocomplete|
  click_on 'get'
  assert_equal 1, evaluate_script("$('input[name=#{input_name}]').focus().length")
  assert_equal 1, evaluate_script("$('.apidocs-param-tips.#{autocomplete}:visible').length")
end

Then 'I fill in the API JSON Spec with:' do |spec|
  selector = 'textarea#api_docs_service_body ~ .CodeMirror'

  find(:css, selector)

  page.evaluate_script <<-JS
    document.querySelector(#{selector.to_json}).CodeMirror.setValue(#{spec.to_json})
  JS
end
