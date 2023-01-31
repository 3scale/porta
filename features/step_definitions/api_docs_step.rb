# frozen_string_literal: true

Given(/^provider "(.*?)" has a swagger 1.0$/) do | org_name |
  provider = Account.providers.find_by org_name: org_name

  active_docs = provider.api_docs_services.build name: "Echo"
  active_docs.published = true
  active_docs.body = file_fixture('swagger/echo-api-1.0.json')
  assert active_docs.save
end

Given(/^provider "(.*?)" has the swagger example of signup$/) do |arg1|
  active_docs = @provider.api_docs_services.build name: "Echo"
  active_docs.published = true
  active_docs.body = file_fixture('swagger/echo-api-2.0.json')
  assert active_docs.save
end

Given(/^provider "(.*?)" has the oas3 simple example$/) do |arg1|
  active_docs = @provider.api_docs_services.build name: "Echo"
  active_docs.published = true
  active_docs.body = file_fixture('swagger/echo-api-3.0.json')
  assert active_docs.save
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
