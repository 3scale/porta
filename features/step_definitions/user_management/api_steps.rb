# frozen_string_literal: true

When "I delete the buyer {string} via API using provider key of {string}" do |buyer_name, provider_name|
  provider_account = Account.find_by!(org_name: provider_name)
  requests = inspect_requests do
    http_request Account.master.domain, :delete, "/users/#{buyer_name}.xml", provider_key: provider_account.api_key
  end
  assert_equal 200, requests.first.status_code
end

When "I update the user {string} with user_key {string} via API using provider key of {string}" do |buyer_name, buyer_key, provider_name|
  provider_account = Account.find_by!(org_name: provider_name)

  requests = inspect_requests do
    http_request Account.master.domain, :put, "/users/#{buyer_name}.xml", provider_key: provider_account.api_key, user_key: buyer_key
  end
  assert_equal 200, requests.first.status_code
end

Then "I should have a user {string} with email {string}" do |buyer_name, buyer_email|
  User.find_by!(username: buyer_name, email: buyer_email)
end

Then "user {string} should have a valid user_key different than {string}" do |buyer_name, old_key|
  user = User.find_by!(username: buyer_name)
  user.account.bought_cinstances.first.user_key.should_not == old_key
end

Then "user {string} should have user_key equal to {string}" do |buyer_name, buyer_key|
  user = User.find_by!(username: buyer_name)
  user.account.bought_cinstances.find_by!(user_key: buyer_key).should_not == nil
end

def http_request(domain, method, path, params)
  Capybara.app_host = "http://#{domain}"
  page.driver.send(method, "http://#{domain}/#{path}", params)
end
