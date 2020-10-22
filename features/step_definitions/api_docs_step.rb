# frozen_string_literal: true

Given "provider {string} has a swagger 1.0$" do |org_name|
  provider = Account.providers.find_by org_name: org_name

  active_docs = provider.api_docs_services.build name: "Echo"
  active_docs.published = true
  active_docs.body = file_fixture('swagger/echo-api-1.0.json')
  assert active_docs.save
end

Given "provider {string} has the swagger example of signup" do |arg1|
  active_docs = @provider.api_docs_services.build name: "Echo"
  active_docs.published = true
  active_docs.body = file_fixture('swagger/echo-api-2.0.json')
  assert active_docs.save
end

Given "provider {string} has the oas3 simple example" do |arg1|
  active_docs = @provider.api_docs_services.build name: "Echo"
  active_docs.published = true
  active_docs.body = file_fixture('swagger/echo-api-3.0.json')
  assert active_docs.save
end

Then "I fill the JSON spec with a valid spec" do
  fill_in "API JSON Spec", with: '{"apis": [{"path": "/admin/api/cms/templates.xml","operations": [{"httpMethod": "GET","summary": "List all templates","description": "List all templates","parameters": [{"name": "provider_key","description": "Your provider key","dataType": "string","required": true,"paramType": "path","allowMultiple": false}]}]}],"namespace": "CMS API","resourcePath": "/admin/api/cms/templates","swagrVersion": "1.1","apiVersion": "1.0"}'
end

Then "swagger should escape properly the curl string" do
  page.click_on 'get'
  page.fill_in 'user_key', with: 'Authorization: Oauth:"test"'
  page.click_button 'Try it out!'
  within '.block.curl' do
    within 'pre' do
      page.should have_content('Authorization: Oauth:"test"')
    end
  end
end

Then "swagger v3 should escape properly the curl string" do
  id = 'default' # Could be passed as arg
  section_id = "#operations-tag-#{id}"

  closed_section = find("#{section_id}[data-is-open='false']")
  closed_section.click

  method_id = "#operations-#{id}-get_"
  closed_method = find(method_id)
  closed_method.click

  within method_id do
    click_on 'Try it out'
    input_name = 'user_key'
    input = find("[data-param-name='#{input_name}'] input")
    input.set 'Authorization: Oauth:"test"'

    click_on 'Execute'

    find('textarea.curl').should have_content('-H Authorization: Oauth:\"test\"')
  end
end

When "I delete the API Spec" do
  page.driver.accept_modal(:confirm) do
    step 'I follow "Delete"'
  end
end
