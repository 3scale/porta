Then /^I should be offered to download an? "(.+?)" file$/ do |mime_type|
  assert_equal mime_type, page.response_headers['Content-Type']
end

Given(/^I'm using a custom API Backend$/) do
  steps %{
    When I go to the integration page for service "one"
    And I fill in "Private Base URL" with "http://www.google.com"
  }
  stub_deploy_calls!

  click_on 'proxy-button-save-and-deploy'
end

Then(/^I should be able to switch back to using the default API Backend$/) do
  link = XPath::HTML.link "Use Echo API"

  page.should have_xpath(link, visible: true)
  find(:xpath, link).click
  page.should_not have_xpath(link, visible: true)
end

Then(/^I can edit the proxy public endpoint$/) do

  step %(I go to the integration page for service "#{@provider.first_service!.name}")

  stub_deploy_calls!
  within('form.staging-settings') do
    fill_in "Public Base URL", with: 'http://echo-api.3scale.net:80'
    click_on 'Save'
  end

  assert_equal  'http://echo-api.3scale.net:80', @provider.first_service!.proxy.endpoint
end

def stub_deploy_calls!
  stub_request(:get, %r{echo-api.3scale.net}).to_return(status: 200)
  stub_request(:get, %r{//test.proxy/deploy/}).to_return(status: 200)
  stub_request(:get, %r{staging.apicast.io}).to_return(status: 200)
end

When 'the proxy has simple secret token' do
  proxy = @provider.first_service!.proxy
  proxy.update_column :secret_token, 'simple'
end

And(/^all the apps have simple user keys$/) do
  Cinstance.where{ user_key.not_eq nil }.update_all(user_key: 'simple')
end

Then(/^I should see the Policy Chain$/) do
  page.should have_css("#policies")
  page.should have_css(".PolicyChain")
  page.should have_css(".Policy")
  page.should have_text("APIcast policy")
  page.should_not have_css(".PolicyRegistryList")
end


Then(%r{^The curl command uses (Basic Authentication|Query|Headers) with app_id/app_key credentials$}) do |authentication|
  matches = {
    'Basic Authentication' => %r{^curl "https?://APP_ID:APP_KEY@},
    'Query' => %r{^curl "https?://.*\?app_id=APP_ID&app_key=APP_KEY"},
    'Headers' => %r{^curl "https?://.*" -H 'app_id: APP_ID' -H 'app_key: APP_KEY'}
  }
  within '#api-test-curl' do
    page.should have_content(matches[authentication])
  end
end

Given(%r{^the service uses app_id/app_key as authentication method$}) do
  @service ||= @provider.default_service
  @service.update_attributes!(backend_version: '2')
end

Given(/^I add a new mapping rule with method "([^"]*)" pattern "([^"]*)" delta "([^"]*)" and metric "([^"]*)"$/) do |method, pattern, delta, metric|
  click_on 'Add Mapping Rule'
  within(page.find('form.proxy_rule')) do
    find("select#proxy_rule_http_method option[value='#{method}']").select_option
    find('input#proxy_rule_pattern').set pattern
    find('input#proxy_rule_delta').set delta
    find('select#proxy_rule_metric_id option', text: metric).select_option
  end
  click_on 'Create Mapping Rule'
end

Given(/^I save the proxy config$/) do
  click_on 'proxy-button-save-and-deploy'
end

MAPPING_RULE_ATTR = %w[http_method pattern delta metric].freeze

Then(/^the mapping rules should be in the following order:$/) do |table|
  data = @provider.default_service.proxy.proxy_rules.includes(:metric).ordered
  data.each_with_index do |mapping_rule, index|
    MAPPING_RULE_ATTR.each do |attr|
      actual_value = mapping_rule.public_send(attr)
      actual_value = actual_value.name if attr == 'metric'
      assert_equal table.hashes[index][attr].to_s, actual_value.to_s
    end
  end
end
