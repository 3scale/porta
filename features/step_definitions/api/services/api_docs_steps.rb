# frozen_string_literal: true

Given /^an admin wants to add a spec to a new service(?: "(.*)")?$/ do |service_name|
  @service = FactoryBot.create(:service, {account: @provider, name: service_name}.compact)
  assert_empty @service.api_docs_services
end

When /^(?:they are|an admin is) reviewing the service's active docs$/ do
  visit admin_service_api_docs_path(@service)
end

When /^(?:they are|an admin is) reviewing the developer portal's active docs$/ do
  visit admin_api_docs_services_path
end

And "submit the ActiveDocs form with {spec_version}" do |swagger_version|
  fill_in('Name', with: 'ActiveDocsName')
  fill_in_api_docs_service_body(spec_body_builder(swagger_version))
  click_on 'Create spec'
end

Then "they should see the new spec" do
  api_doc_service = @service.api_docs_services.last

  assert_flash 'ActiveDocs Spec was successfully saved.'
  assert_current_path preview_admin_service_api_doc_path(service_id: @service.id, id: api_doc_service.id)
  assert_text "Preview Service Spec (#{api_doc_service.swagger_version})"
end

Given "a service with a {spec_version} spec" do |swagger_version|
  @service = FactoryBot.create(:service, account: @provider)
  @api_doc_service = @service.api_docs_services.build(name: "Echo", published: true, body: spec_body_builder(swagger_version))
  @api_doc_service.save
end

And "an admin wants to update the spec" do
  visit edit_admin_service_api_doc_path(service_id: @service.id, id: @api_doc_service.id)
end

When "they try to update the spec with invalid data" do
  fill_in('Name', with: '')
  assert has_button?('Update spec', disabled: true)
  fill_in('Name', with: 'Invalid')
  fill_in_api_docs_service_body('Invalid')
  click_on 'Update spec'
end

When "they try to update the spec with an invalid JSON spec" do
  fill_in_api_docs_service_body('{"swagger": "foo"}')
  click_on 'Update spec'
end

When "they try to update the spec with valid data" do
  @new_service = Service.find_by!(name: 'New service')
  find('#api_docs_service_name').set('NewActiveDocsName')
  assert find('input[name="api_docs_service[system_name]"]').disabled?
  check 'Publish?'
  fill_in('Description', with: 'New description')
  pf4_select(@new_service.name, from: 'Service')
  fill_in_api_docs_service_body(FactoryBot.build(:api_docs_service).body)
  check 'Skip swagger validations'
  click_on 'Update spec'
end

Then "they should see the errors" do
  assert has_css?('#api_docs_service_body ~ .pf-m-error', text: I18n.t('activemodel.errors.models.three_scale/swagger/specification.invalid_json'))
end

Then "they should see the swagger is invalid" do
  assert has_css?('#api_docs_service_body ~ .pf-m-error', text: I18n.t('activemodel.errors.models.three_scale/swagger/specification.invalid_swagger'))
end

Then "they should see the updated spec" do
  assert has_css?('.operations', text: 'Hide')
  assert has_text?('My spec')
  assert_flash 'ActiveDocs Spec was successfully updated.'
  assert_equal @new_service.id, @api_doc_service.reload.service_id
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

Then "the swagger autocomplete should work for {string} with {string}" do |input_name, autocomplete|
  find('span', text: /get/i).click
  has_css?(".apidocs-param-tips.#{autocomplete}", visible: :hidden)
  find("input[name=#{input_name}]").click
  assert has_css?(".apidocs-param-tips.#{autocomplete}", visible: :visible)
end

Then "{spec_version} should escape properly the curl string" do |swagger_version|
  find('span', text: /get/i).click
  assert find(:xpath, '//*[@name="user_key"]/..').has_sibling? 'td', text: 'header'
  page.fill_in 'user_key', with: 'Authorization: Oauth:"test"'
  page.click_button 'Try it out!'
  curl_commmand = find_all('div', text: /curl/i).last
  assert curl_commmand.has_text?(swagger_version == '1.2' ? 'Authorization: Oauth:\"test\"' : 'Authorization: Oauth:"test"')
end

Then "the table {should} contain a column for the service" do |should|
  within 'table thead' do
    assert_equal should, has_content?('API')
  end

  within 'table tbody' do
    assert_equal should, has_content?(@service.name)
  end
end
