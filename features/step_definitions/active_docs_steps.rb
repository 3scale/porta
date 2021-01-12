# frozen_string_literal: true

Given "the provider has {int} active doc(s)" do |number_active_docs|
  @active_docs = FactoryBot.create_list(:api_docs_service, number_active_docs, account: @provider, service: @provider.default_service)
end

When "I try to {word} the active docs with {valid} data" do |action, valid|
  action_active_docs(action, valid)
end

When "I try to {word} the active docs of the service with {valid} data" do |action, valid|
  action_active_docs(action, valid, for_service: true)
end

def action_active_docs(action, valid, for_service: false)
  action_page = action == 'update' ? 'edit' : 'new'
  step %(I go to the #{action_page} active docs page#{' for a service' if for_service})
  step %(I #{action} the active docs with #{valid ? 'valid' : 'invalid'} data)
end

When "I {word} the active docs with {valid} data" do |action, valid|
  fill_in('Name', with: 'ActiveDocsName')
  api_spec = valid ? FactoryBot.build(:api_docs_service).body : 'invalid'
  fill_in('API JSON Spec', with: api_spec)
  click_on "#{action.capitalize!} Spec"
end

When "I select a service from the service selector" do
  select(@provider.default_service.name, from: 'api_docs_service_service_id')
end

Then 'I should see the active docs errors in the page' do
  step 'I should see "JSON Spec is invalid"'
end

Then "the table {should} contain the API" do |should|
  should = should ? 'should' : 'should not'
  step %(I #{should} see "API" within the table header)
  step %(I #{should} see "#{@provider.default_service.name}" within the table body)
end

Then "the service selector is not in the form" do
  refute has_xpath?('//form//select[@id="api_docs_service_service_id"]')
end

Then "the api doc spec is saved with this service linked" do
  assert_selector('.flash-message--notice', text: /ActiveDocs Spec was successfully (saved|updated)./)
end

Then "the swagger autocomplete should work for {string} with {string}" do |input_name, autocomplete|
  click_on 'get'
  wait_for_requests
  assert_equal 1, evaluate_script("$('input[name=#{input_name}]').focus().length")
  assert_equal 1, evaluate_script("$('.apidocs-param-tips.#{autocomplete}:visible').length")
end

Then "I fill in the API JSON Spec with:" do |spec|
  selector = 'textarea#api_docs_service_body ~ .CodeMirror'

  find(:css, selector)

  page.evaluate_script <<-JS
    document.querySelector(#{selector.to_json}).CodeMirror.setValue(#{spec.to_json})
  JS
end
