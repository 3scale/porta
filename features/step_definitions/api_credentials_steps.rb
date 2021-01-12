# frozen_string_literal: true

# API v1:
Given "{buyer} has user key {string}" do |buyer, key|
  buyer.bought_cinstance.update!(user_key: key)
end

Then /^I should see (the application id of buyer "[^"]*")$/ do |value|
  step %(I should see "#{value}")
end

Then "I should see the {user_key_of_buyer}" do |key|
  step %(I should see "#{key}")
end

# API v2/multiple apps
Then "I should see the ID of {application}" do |application|
  step %(I should see "#{application.application_id}")
end

Then "I should not see the ID of {application}" do |application|
  step %(I should not see "#{application.application_id}")
end

# API v2/single app
Then "I should see the ID of the application of {buyer}" do |buyer|
  step %(I should see "#{buyer.bought_cinstance.application_id}")
end

# All
Then "I should see the provider key of {provider}" do |provider|
  step %(I should see "#{provider.api_key}")
end
