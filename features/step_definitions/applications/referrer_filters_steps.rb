# multi-app

Given /^(application "[^"]*") has the following referrer filters:$/ do |application, table|
  fake_application_referrer_filters(application, table.raw.map(&:first))
end

Given /^(application "[^"]*") has no referrer filters$/ do |application|
  fake_application_referrer_filters(application, [])
end

Given /^the backend will create referrer filter "([^"]*)" for (application "[^"]*")$/ do |referrer_filter, application|
  fake_application_referrer_filter_creation(application, referrer_filter)
end

Given /^the backend will delete referrer filter "([^"]*)" for (application "[^"]*")$/ do |referrer_filter, application|
  fake_application_referrer_filter_deletion(application, referrer_filter)
end

Given /^the backend will respond with error on attempt to create blank referrer filter for (application "[^"]*")$/ do |application|
  fake_application_referrer_filter_creation_error(application)
end

Given /^the referrer filter limit for (application "[^"]*") is reached$/ do |application|
  filters = Array.new(application.filters_limit) do |i|
    "#{i}.example.org"
  end

  fake_application_referrer_filters(application, filters)
end


# need to touch the session, so it can be reset later
def touch_session
  page.execute_script('')
rescue Capybara::NotSupportedByDriverError
  false
end

def rack_test_http_request(method, path, args = nil)
  touch_session
  page.driver.browser.process_and_follow_redirects(method, path, args)
end

When /^I do POST to the referrer filters url for (application "[^"]*")$/ do |application|
  rack_test_http_request :post, admin_application_referrer_filters_path(application)
end

When /^I do DELETE to the "([^"]*)" referrer filter url for (application "[^"]*")$/ do |filter, application|
  rack_test_http_request :delete, admin_application_referrer_filter_path(application, ReferrerFilter.find_by_value(filter).id)
end

# single-app

Given /^the application of (buyer "[^"]*") has the following referrer filters:$/ do |buyer, table|
  fake_application_referrer_filters(buyer.bought_cinstance, table.raw.map(&:first))
end

Given /^the application of (buyer "[^"]*") has no referrer filters$/ do |buyer|
  fake_application_referrer_filters(buyer.bought_cinstance, [])
end

Given /^the backend will create referrer filter "([^"]*)" for the application of (buyer "[^"]*")$/ do |referrer_filter, buyer|
  fake_application_referrer_filter_creation(buyer.bought_cinstance, referrer_filter)
end

Given /^the backend will respond with error on attempt to create blank referrer filter for the application of (buyer "[^"]*")$/ do |buyer|
  fake_application_referrer_filter_creation_error(buyer.bought_cinstance)
end

Given /^the backend will delete referrer filter "([^"]*)" for the application of (buyer "[^"]*")$/ do |referrer_filter, buyer|
  fake_application_referrer_filter_deletion(buyer.bought_cinstance, referrer_filter)
end

When /^I do POST to the referrer filters url for the application of (buyer "[^"]*")$/ do |buyer|
  rack_test_http_request :post, application_referrer_filters_path(buyer.bought_cinstance)
end


# single/multi app

When /^I submit the new referrer filter form with "([^"]*)"$/ do |value|
  within '#referrer_filters' do
    fill_in 'referrer_filter', :with => value
    click_button 'Add'
  end
end

When /^I press "([^"]*)" for referrer filter "([^"]*)"$/ do |label, filter|
  rf = ReferrerFilter.find_by_value filter
  step %(I press "#{label}" within "#referrer_filter_#{rf.id}")
end

Then /^I should see referrer filters limit reached error$/ do
  assert has_content?("At most #{ReferrerFilter::REFERRER_FILTERS_LIMIT} referrer filters are allowed.")
end

Then /^I should see referrer filter "([^"]*)"$/ do |filter|
  step %(I should see "#{filter}" within "#referrer_filters")
end

Then /^I should not see referrer filter "([^"]*)"$/ do |filter|
  step %(I should not see "#{filter}" within "#referrer_filters")
end

Then /^I should see referrer filter validation error "([^"]*)"$/ do |error|
  step %(I should see "#{error}" within "#referrer_filters")
end

Then /^the new referrer filter form should be hidden$/ do
  assert has_no_xpath? "//div[@id='referrer_filters']/div[@class='enabled_block']"
end

Given /^referrer filters are( not)? required for the service of (provider "[^"]*")$/ do |disabled, provider|
  provider.default_service.update_attribute(:referrer_filters_required, disabled.blank?)
end

Then /^referrer filters should be required for the service of (provider "[^"]*")$/ do |provider|
  assert provider.default_service.referrer_filters_required?
end

Then /^referrer filters should not be required for the service of (provider "[^"]*")$/ do |provider|
  assert !provider.default_service.referrer_filters_required?
end

def fake_application_referrer_filters(application, filters)
  ReferrerFilter.without_backend do
    filters.each do |filter|
      application.referrer_filters.add(filter)
    end
  end
end

def fake_application_referrer_filter_creation(application, value)
  FakeWeb.register_uri(
    :post, backend_application_url(application, '/referrer_filters.xml'),
    :status => fake_status(201),
    :body   => %(<referrer_filter value="#{value}"/>))
end

def fake_application_referrer_filter_creation_error(application)
  FakeWeb.register_uri(
    :post, backend_application_url(application, '/referrer_filters.xml'),
    :status => fake_status(422),
    :body   => %(<error>referrer filter can't be blank</error>))
end

def fake_application_referrer_filter_deletion(application, value)
  FakeWeb.register_uri(
    :delete, backend_application_url(application, "/referrer_filters/#{value}.xml?provider_key=#{application.provider_account.api_key}&service_id=#{application.service.backend_id}"),
    :status => fake_status(200), :body => '')
end
