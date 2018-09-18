When /^I delete the buyer "([^\"]*)" via API using provider key of "([^\"]*)"$/ do |buyer_name, provider_name|
  provider_account = Account.find_by_org_name!(provider_name)
  service = provider_account.first_service!

  http_request Account.master.domain, :delete, "/users/#{buyer_name}.xml", :provider_key => provider_account.api_key
  assert_equal 200, page.status_code
end




When /^I update the user "([^\"]*)" with user_key "([^\"]*)" via API using provider key of "([^\"]*)"$/ do |buyer_name, buyer_key, provider_name|
  provider_account = Account.find_by_org_name!(provider_name)

  http_request Account.master.domain, :put, "/users/#{buyer_name}.xml", :provider_key => provider_account.api_key, :user_key => buyer_key
  assert_equal 200, page.status_code
end

Then /^I should have a user "([^\"]*)" with email "([^\"]*)"$/ do |buyer_name, buyer_email|
  user = User.find_by_username_and_email(buyer_name, buyer_email)
end

Then /^user "([^\"]*)" should have a valid user_key different than "([^\"]*)"$/ do |buyer_name, old_key|
  user = User.find_by_username(buyer_name)
  user.account.bought_cinstances.first.user_key.should_not == old_key
end

Then /^user "([^\"]*)" should have user_key equal to "([^\"]*)"$/ do |buyer_name, buyer_key|
  user = User.find_by_username(buyer_name)
  user.account.bought_cinstances.find_by_user_key(buyer_key).should_not == nil
end

def http_request(domain, method, path, params)
  Capybara.app_host = "http://#{domain}"
  page.driver.send(method, "http://#{domain}/#{path}", params)
end
