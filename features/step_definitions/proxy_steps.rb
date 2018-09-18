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
