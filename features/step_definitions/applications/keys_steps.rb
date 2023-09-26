# rubocop:disable Style/HashEachMethods
# frozen_string_literal: true

Given "the key limit for {application} is reached" do |application|
  fake_application_keys_count(application, application.keys_limit)
end

Given /^I don't care about application keys$/ do
  stub_backend_get_keys
end

Given "{application} has the following keys:" do |application, table|
  fake_application_keys(application, table.raw.map(&:first))
end

Given "{application} has {int} key(s)" do |application, number|
  assert number >= 0
  keys = application.application_keys
  keys.delete_all
  number.times.each { |key| keys.add(nil) }
end

Given "{application} has no keys" do |app|
  app.application_keys.delete_all
end

Then "{application} shows {int} key(s)" do |application, number|
  wait_for_requests
  assert_equal number, find_all('table#keys tbody tr.key').length
end

Given "the application of {buyer} has the following keys:" do |buyer, table|
  fake_application_keys(buyer.bought_cinstance, table.raw.map(&:first))
end

Given "the application of {buyer} has {int} keys" do |buyer, number|
  fake_application_keys_count(buyer.bought_cinstance, number)
end

Given "the backend will create key {string} for {application}" do |key, application|
  stub_request(:post, backend_application_url(application, '/keys.xml'))
    .to_return(status: fake_status(201), body: %(<key value="#{key}"/>))
  fake_application_keys(application, [key])
end

Given /^the backend will create key "([^"]*)" for an application$/ do |key|
  stub_request(:post, %r{/applications/(.*)/keys.xml(.*)})
    .to_return(status: fake_status(201), body: %(<key value="#{key}"/>))

  stub_request(:get, %r{/applications/(.*)/keys.xml(.*)})
    .to_return(status: fake_status(200), body: %(<keys><key value="#{key}"</key>))
end

Given "the backend will delete key {string} for {application}" do |key, application|
  stub_request(:delete, backend_application_url(application, "/keys/#{key}.xml?provider_key=#{application.provider_account.api_key}&service_id=#{application.service.backend_id}"))
    .to_return(status: fake_status(200), body: '')
end

When /^I (press|follow) "([^"]*)" for application key "([^"]*)"$/ do |action, label, key|
  step %(I #{action} "#{label}" within "#application_key_#{key}")
end

When /^I (press|follow) "([^"]*)" for first application key$/ do |action, label|
  within "#keys .key:nth-child(2) .key" do
    step %(I #{action} "#{label}")
  end
end

Then /^I should see application key "([^"]*)"$/ do |key|
  step %(I should see "#{key}" within "#application_keys")
end

Then "I should see all keys of {application}" do |application|
  application.keys.each do |key|
    step %(I should see "#{key}")
  end
end

Then "I should not see any key of {application}" do |application|
  application.keys.each do |key|
    step %(I should not see "#{key}")
  end
end

Then "I should see all keys of the application of {buyer}" do |buyer|
  buyer.bought_cinstance.keys.each do |key|
    step %(I should see "#{key}")
  end
end

def limit_warning
  find("#app-keys-limit-warning", visible: :any)
end

Then /^I should see application keys limit reached error$/ do
  wait_for_requests
  within '#application_keys' do
    limit_warning.should be_visible
  end
end

Then "no more keys can be added" do
  wait_for_requests
  within '#application_keys' do
    limit_warning.should be_visible
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

Then "(any of )the application keys {can} be deleted" do |deleteable|
  within '#application_keys' do
    @application.application_keys.each do |key|
      assert_equal deleteable, has_css?("tr##{dom_id key} a.delete", visible: true)
    end
  end
end

Given "{application}'s product {has} mandatory app key" do |application, mandatory|
  application.service.update!(mandatory_app_key: mandatory)
end

# rubocop:enable Style/HashEachMethods
