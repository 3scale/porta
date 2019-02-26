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
  page.should have_css(".PolicyRegistryList.is-hidden")

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
  click_on 'add-proxy-rule'
  within(page.find('#sortable tr:last-child')) do
    find("td.http_method select option[value='#{method}']").select_option
    find('td.pattern input').set pattern
    find('td.delta input').set delta
    find('td.metric select').find(:xpath, "//*[.='#{metric}']").select_option
  end
end

Given(/^I drag the last mapping rule to the position (\d+)$/) do |position|
  within(page.find('#sortable')) do
    last_index = all('tr').count
    element = page.find("tr:nth-child(#{last_index}) a.ui-sortable-handler")
    target = page.find("tr:nth-child(#{position})")
    element.drag_to(target)
  end
end

Given(/^I save the proxy config$/) do
  click_on 'proxy-button-save-and-deploy'
end

Then(/^the mapping rules should be in the following order:$/) do |table|
  data = @provider.default_service.proxy.proxy_rules.ordered
  MAPPING_RULE_ATTR = %w[http_method pattern delta metric_id].freeze
  data.each_with_index do |mapping_rule, index|
    MAPPING_RULE_ATTR.each do |attr|
      assert_equal table.hashes[index][attr].to_s, mapping_rule[attr].to_s
    end
  end
end
