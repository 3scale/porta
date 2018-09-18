Then /^provider "([^"]*)" should have access to useful account data$/ do |name|
  account = Account.find_by_org_name(name)
  provider_admin = account.admins.first
  app = account.provided_cinstances.first
  service = account.services.first
  buyer = account.buyer_accounts.first
  buyer_admin = buyer.admins.first
  metric = account.metrics.first
  application_plans = account.application_plans.latest
  account_plans = account.account_plans.latest
  service_plans = account.service_plans.latest

  service.update_attributes!(:backend_version => 1)
  visit  provider_admin_api_docs_account_data_path(:format => :json)

  expected_json = {
    results: {
      app_keys: [],
      app_ids: [],
      client_ids: [],
      client_secrets: [],
      user_keys: [{name: "#{app.name} - #{app.service.name}", value: app.user_key }],
      admin_ids: [{name: provider_admin.username, value: provider_admin.id}],
      metric_names: [{name: "#{metric.friendly_name} | #{metric.service.name}", value: metric.name}],
      metric_ids: [{name: "#{metric.friendly_name} | #{metric.service.name}", value: metric.id}],
      service_ids: [{name: service.name, value: service.id}],
      application_ids: [{name: "#{app.name} | #{app.service.name}", value: app.id}],
      account_ids: [{name: buyer.name, value: buyer.id}],
      user_ids: [{name: buyer_admin.username, value: buyer_admin.id}],
      service_plan_ids: [{name: "#{service_plans[0].name} | #{service_plans[0].service.name}", value: service_plans[0].id}],
      account_plan_ids: [{name: account_plans[0].name, value: account_plans[0].id}],
      application_plan_ids: [{name: "#{application_plans[0].name} | #{application_plans[0].service.name}", value: application_plans[0].id}],
      access_token: [{ name: 'First create an access token in the Personal Settings section.', value: ''}],
      service_tokens: [{ name: service.name, value: service.service_token }]
    },
    status: 200
  }.to_json

  expected = JSON.parse(expected_json)
  actual   = JSON.parse(page.source)
  actual.should == expected
end

Then /^"([^"]*)" should have access to useful account data$/ do |name|
  account = Account.find_by_org_name(name)

  app = account.bought_cinstances.first
  app.service.update_attributes!(:backend_version => 2)
  visit api_docs_account_data_path(:format => :json)

  expected_json = {
    results: {
      app_keys: [{:name => "#{app.name} - #{app.service.name}", :value => (app.keys.first || "")}],
      app_ids: [{:name => "#{app.name} - #{app.service.name}", :value => app.application_id}],
      user_keys: [],
      client_secrets: [],
      client_ids: [],
    },
    status: 200
  }.to_json

  expected = JSON.parse(expected_json)
  actual   = JSON.parse(page.source)
  actual.should == expected
end

Then /I should not have access to useful account data$/ do
  visit api_docs_account_data_path(:format => :json)

  expected_json = {:status => 401}.to_json

  expected = JSON.parse(expected_json)
  actual   = JSON.parse(page.source)
  actual.should == expected
end

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
