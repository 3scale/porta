# frozen_string_literal: true

Given(/^provider "(.*?)" has a swagger 1.0$/) do | org_name |
  provider = Account.providers.find_by_org_name org_name

  active_docs = provider.api_docs_services.build name: "Echo"
  active_docs.published = true
  active_docs.body =<<EOBODY
{
 "basePath": "https://echo-api.3scale.net",
 "apiVersion": "v1",
 "swaggerVersion": "1.0",
 "apis": [
   {
     "path": "/hello",
     "operations": [
       {
         "httpMethod": "GET",
         "summary": "Say Hello!",
         "description": "This operation says hello.",
         "nickname": "hello",
         "group": "words",
         "type": "string",
         "parameters": [
           {
             "name": "user_key",
             "description": "Your API access key",
             "type": "string",
             "paramType": "query",
             "threescale_name": "user_keys"
           }
         ]
       }
     ]
   }
 ]
}
EOBODY
  assert active_docs.save
end

Given(/^provider "(.*?)" has the swagger example of signup$/) do |arg1|
  active_docs = @provider.api_docs_services.build name: "Echo"
  active_docs.published = true
  active_docs.body = Logic::ProviderSignup::SampleData::ECHO_SERVICE
  assert active_docs.save
end

Then /I fill the JSON spec with a valid spec/ do
  fill_in "API JSON Spec", with: '{"apis": [{"path": "/admin/api/cms/templates.xml","operations": [{"httpMethod": "GET","summary": "List all templates","description": "List all templates","parameters": [{"name": "provider_key","description": "Your provider key","dataType": "string","required": true,"paramType": "path","allowMultiple": false}]}]}],"namespace": "CMS API","resourcePath": "/admin/api/cms/templates","swagrVersion": "1.1","apiVersion": "1.0"}'
end

Then(/^swagger should escape properly the curl string$/) do
  page.click_on 'get'
  page.fill_in 'user_key', with: 'Authorization: Oauth:"test"'
  page.click_button 'Try it out!'
  within '.block.curl' do
    within 'pre' do
      page.should have_content('Authorization: Oauth:"test"')
    end
  end
end


When(/^I delete the API Spec$/) do
  page.driver.accept_modal(:confirm) do
    step 'I follow "Delete"'
  end
end
