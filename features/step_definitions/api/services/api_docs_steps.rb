# frozen_string_literal: true

Given "an admin wants to add a spec to a new service" do
  @service = FactoryBot.create(:service, account: @provider)
  assert_empty @service.api_docs_services
end

When /^(?:they are|an admin is) reviewing the service's active docs$/ do
  visit admin_service_api_docs_path(@service)
end

And "submit the ActiveDocs form" do
  fill_in('Name', with: 'ActiveDocsName')
  fill_in_api_docs_service_body(FactoryBot.build(:api_docs_service).body)
  click_on 'Create spec'
end

Then "they should see the new spec" do
  assert_flash 'ActiveDocs Spec was successfully saved.'
  assert_current_path preview_admin_service_api_doc_path(service_id: @service.id, id: @service.api_docs_services.last.id)
  assert_text 'Preview Service Spec (2.0)'
end

Given "a service with a spec" do
  @service = FactoryBot.create(:service, account: @provider)
  @api_doc_service = @service.api_docs_services.build(name: "Echo", published: true, body: file_fixture('swagger/echo-api-2.0.json'))
  @api_doc_service.save
end

And "an admin wants to update the spec" do
  visit edit_admin_service_api_doc_path(service_id: @service.id, id: @api_doc_service.id)
end

When "they try to update the spec with invalid data" do
  fill_in('Name', with: '')
  fill_in_api_docs_service_body('Invalid')
  click_on 'Update spec'
end

When "they try to update the spec with valid data" do
  find('#api_docs_service_name').set('NewActiveDocsName')
  check 'Publish?'
  fill_in('Description', with: 'New description')
  pf4_select('New service', from: 'Service')
  fill_in_api_docs_service_body(FactoryBot.build(:api_docs_service).body)
  check 'Skip swagger validations'
  click_on 'Update spec'
end

def fill_in_api_docs_service_body(value)
  # HACK: fill_in('API JSON Spec', visible: :hidden, with: FactoryBot.build(:api_docs_service).body) doesn't work because capybara rises ElementNotInteractableError
  page.execute_script("$('textarea#api_docs_service_body').css('display','')")
  find('textarea#api_docs_service_body').set(value)
  find('.pf-c-page__main-section').click # HACK: need to click outside to lose focus
end

Then "they should see the errors" do
  assert has_css?('#api_docs_service_name ~ .pf-m-error', text: "can't be blank")
  assert has_css?('#api_docs_service_body ~ .pf-m-error', text: "JSON Spec is invalid")
end

Then "they should see the updated spec" do
  assert has_css?('.operations', text: 'Hide')
  assert has_text?('My spec') # Comes from Factory
  assert_flash 'ActiveDocs Spec was successfully updated.'
  assert_equal Service.find_by!(name: 'New service').id, @api_doc_service.reload.service_id
end

Then "an admin can edit the spec" do
  visit admin_api_docs_services_path
  assert has_css?('h1', text: 'ActiveDocs')
  find('tr td', text: @api_doc_service.name).sibling('.operations').click_link("Edit")
end

When "an admin is reviewing the spec" do
  visit preview_admin_service_api_doc_path(service_id: @service.id, id: @api_doc_service.id)
end

Then "they can hide an publish the spec" do
  find('.operations .action', text: 'Hide').click
  assert_flash "#{@api_doc_service.name} unpublished"
  find('.operations .action', text: 'Publish').click
  assert_flash "#{@api_doc_service.name} published"
end

Then "they can delete the spec" do
  accept_confirm do
    find('.operations .action', text: 'Delete').click
  end
  assert_flash "ActiveDocs Spec was successfully deleted."
end

Then "they can review the spec" do
  find('tr td', text: @api_doc_service.name).click
end

# Then /^the table should( not)? contain the API$/ do |negate|
#   step "I should#{negate} see \"API\" within the table header"
#   step "I should#{negate} see \"#{@provider.default_service.name}\" within the table body"
# end

# Then(/^the service selector is not in the form$/) do
#   refute has_xpath?('//form//select[@id="api_docs_service_service_id"]')
# end

# Then(/^the api doc spec is saved with this service linked$/) do
#   assert_selector('.flash-message--notice', text: /ActiveDocs Spec was successfully (saved|updated)./)
# end

# Then(/^the swagger autocomplete should work for "(.*?)" with "(.*?)"$/) do |input_name, autocomplete|
#   click_on 'get'
#   wait_for_requests
#   assert_equal 1, evaluate_script("$('input[name=#{input_name}]').focus().length")
#   assert_equal 1, evaluate_script("$('.apidocs-param-tips.#{autocomplete}:visible').length")
# end

# frozen_string_literal: true

# Given(/^provider "(.*?)" has a swagger 1.0$/) do | org_name |
#   provider = Account.providers.find_by org_name: org_name

#   active_docs = provider.api_docs_services.build name: "Echo"
#   active_docs.published = true
#   active_docs.body = file_fixture('swagger/echo-api-1.0.json')
#   assert active_docs.save
# end

# Given(/^provider "(.*?)" has the swagger example of signup$/) do |arg1|
#   active_docs = @provider.api_docs_services.build name: "Echo"
#   active_docs.published = true
#   active_docs.body = file_fixture('swagger/echo-api-2.0.json')
#   assert active_docs.save
# end

# Given(/^provider "(.*?)" has the oas3 simple example$/) do |arg1|
#   active_docs = @provider.api_docs_services.build name: "Echo"
#   active_docs.published = true
#   active_docs.body = file_fixture('swagger/echo-api-3.0.json')
#   assert active_docs.save
# end

# Then /I fill the JSON spec with a valid spec/ do
#   fill_in "API JSON Spec", with: '{"apis": [{"path": "/admin/api/cms/templates.xml","operations": [{"httpMethod": "GET","summary": "List all templates","description": "List all templates","parameters": [{"name": "provider_key","description": "Your provider key","dataType": "string","required": true,"paramType": "path","allowMultiple": false}]}]}],"namespace": "CMS API","resourcePath": "/admin/api/cms/templates","swagrVersion": "1.1","apiVersion": "1.0"}'
# end

# Then(/^swagger should escape properly the curl string$/) do
#   page.click_on 'get'
#   page.fill_in 'user_key', with: 'Authorization: Oauth:"test"'
#   page.click_button 'Try it out!'
#   within '.block.curl' do
#     within 'pre' do
#       page.should have_content('Authorization: Oauth:"test"')
#     end
#   end
# end

# Then(/^swagger v3 should escape properly the curl string$/) do
#   id = 'default' # Could be passed as arg
#   section_id = "#operations-tag-#{id}"

#   closed_section = find("#{section_id}[data-is-open='false']")
#   closed_section.click

#   method_id = "#operations-#{id}-get_"
#   closed_method = find(method_id)
#   closed_method.click

#   within method_id do
#     click_on 'Try it out'
#     input_name = 'user_key'
#     input = find("[data-param-name='#{input_name}'] input")
#     input.set 'Authorization: Oauth:"test"'

#     click_on 'Execute'

#     find('textarea.curl').should have_content('-H Authorization: Oauth:\"test\"')
#   end
# end
