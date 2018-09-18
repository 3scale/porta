Given /^the key limit for (application "[^"]*") is reached$/ do |application|
  fake_application_keys_count(application, application.keys_limit)
end

Given /^I don't care about application keys$/ do
  stub_backend_get_keys
end

Given /^I care about application keys$/ do
  unstub_backend_get_keys
end

Given /^(application "[^"]*") has the following keys:$/ do |application, table|
  fake_application_keys(application, table.raw.map(&:first))
end

Given /^(application "[^"]*") has (\d+) keys$/ do |application, number|
  fake_application_keys_count(application, number)
end

Given /^application "([^"]*)" has no keys$/ do |name|
  step %(application "#{name}" has 0 keys)
end

Given /^the application of (buyer "[^"]*") has the following keys:$/ do |buyer, table|
  fake_application_keys(buyer.bought_cinstance, table.raw.map(&:first))
end

Given /^the application of (buyer "[^"]*") has (\d+) keys$/ do |buyer, number|
  fake_application_keys_count(buyer.bought_cinstance, number)
end

Given /^the backend will create key "([^"]*)" for (application "[^"]*")$/ do |key, application|
  FakeWeb.register_uri(:post, backend_application_url(application, "/keys.xml"),
                       :status => fake_status(201),
                       :body => %(<key value="#{key}"/>))
  fake_application_keys(application, [key])
end

Given /^the backend will create key "([^"]*)" for an application$/ do |key|
  FakeWeb.register_uri(:post, %r|/applications/(.*)/keys.xml(.*)|,
                       :status => fake_status(201),
                       :body => %(<key value="#{key}"/>))

  FakeWeb.register_uri(:get, %r|/applications/(.*)/keys.xml(.*)|,
                       :status => fake_status(200),
                       :body => %(<keys><key value="#{key}"</key>))
end

Given /^the backend will delete key "([^"]*)" for (application "[^"]*")$/ do |key, application|
  FakeWeb.register_uri(
    :delete, backend_application_url(application, "/keys/#{key}.xml?provider_key=#{application.provider_account.api_key}&service_id=#{application.service.backend_id}"),
    :status => fake_status(200),  :body => '')
end

Given %r{^the backend will delete all keys for (application "[^"]*")$} do |application|
  application.keys.each do |key|
    step %{the backend will delete key "#{key}" for application "#{application.name}"}
  end
end



When /^I (press|follow) "([^"]*)" for application key "([^"]*)"$/ do |action, label, key|
  step %(I #{action} "#{label}" within "#application_key_#{key}")
end

When %r{^I (press|follow) "([^"]*)" for last application key$} do |action, label|
  within "#keys .key:last-child .key" do
    step %{I #{action} "#{label}"}
  end
end

When %r{^I (press|follow) "([^"]*)" for first application key$} do |action, label|
  within "#keys .key:nth-child(2) .key" do
    step %{I #{action} "#{label}"}
  end
end

Then /^I should see application key "([^"]*)"$/ do |key|
  step %(I should see "#{key}" within "#application_keys")
end

Then /^I should not see application key "([^"]*)"$/ do |key|
  step %(I should not see "#{key}" within "#application_keys")
end

Then /^I should see all keys of (application "[^"]*")$/ do |application|
  application.keys.each do |key|
    step %(I should see "#{key}")
  end
end

Then /^I should not see any key of (application "[^"]*")$/ do |application|
  application.keys.each do |key|
    step %(I should not see "#{key}")
  end
end

Then /^I should see all keys of the application of (buyer "[^"]*")$/ do |buyer|
  buyer.bought_cinstance.keys.each do |key|
    step %(I should see "#{key}")
  end
end

def limit_warning
  find("#app-keys-limit-warning")
end

Then /^I should see application keys limit reached error$/ do
  within '#application_keys' do
    limit_warning.should be_visible
  end
end

Then /^I should(?:n't| not) see application keys limit reached error$/ do
  within '#application_keys' do
    limit_warning.should_not be_visible
  end
end

Then /^I should not see the application keys$/ do
  assert page.has_no_content?("Application Keys")
end

Then /^the key "(.+?)" should(?:n't| not) be deleteable$/ do |key|
  within "#application_key_#{key}" do
    assert find("td.delete_key").has_no_content?("Delete")
  end
end
