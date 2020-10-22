# frozen_string_literal: true

# multi-app

Given "{application} has the following referrer filters:" do |application, table|
  fake_application_referrer_filters(application, table.raw.map(&:first))
end

Given "{application} has no referrer filters" do |application|
  fake_application_referrer_filters(application, [])
end

Given "the backend will create referrer filter {string} for {application}" do |referrer_filter, application|
  fake_application_referrer_filter_creation(application, referrer_filter)
end

Given "the backend will delete referrer filter {string} for {application}" do |referrer_filter, application|
  fake_application_referrer_filter_deletion(application, referrer_filter)
end

Given "the backend will respond with error on attempt to create blank referrer filter for {application}" do |application|
  fake_application_referrer_filter_creation_error(application)
end

Given "the referrer filter limit for {application} is reached" do |application|
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

# single-app

Given "the application of {buyer} has the following referrer filters" do |buyer, table|
  fake_application_referrer_filters(buyer.bought_cinstance, table.raw.map(&:first))
end

Given "the application of {buyer} has no referrer filters" do |buyer|
  fake_application_referrer_filters(buyer.bought_cinstance, [])
end

Given "the backend will create referrer filter {string} for the application of {buyer}" do |referrer_filter, buyer|
  fake_application_referrer_filter_creation(buyer.bought_cinstance, referrer_filter)
end

Given "the backend will respond with error on attempt to create blank referrer filter for the application of {buyer}" do |buyer|
  fake_application_referrer_filter_creation_error(buyer.bought_cinstance)
end

Given "the backend will delete referrer filter {string} for the application of {buyer}" do |referrer_filter, buyer|
  fake_application_referrer_filter_deletion(buyer.bought_cinstance, referrer_filter)
end

# single/multi app

When "I submit the new referrer filter form with {string}" do |value|
  within '#referrer_filters' do
    fill_in 'referrer_filter', with: value
    click_button 'Add'
  end
  block_and_wait_for_requests_complete
end

When "I press {string} for referrer filter {string}" do |label, filter|
  rf = ReferrerFilter.find_by!(value: filter)
  step %(I press "#{label}" within "#referrer_filter_#{rf.id}")
end

Then "I should see referrer filters limit reached error" do
  assert has_content?("At most #{ReferrerFilter::REFERRER_FILTERS_LIMIT} referrer filters are allowed.")
end

Then "I {should} see referrer filter {string}" do |visible, filter|
  step %(I should #{visible ? '' : 'not '}see "#{filter}" within "#referrer_filters")
end

Then "I should see referrer filter validation error {string}" do |error|
  step %(I should see "#{error}" within "#referrer_filters")
end

Then "the new referrer filter form should be hidden" do
  assert has_no_xpath? "//div[@id='referrer_filters']/div[@class='enabled_block']"
end

Given "referrer filters {are} required for the service of {provider}" do |required, provider|
  provider.default_service.update!(referrer_filters_required: required)
end

Then "referrer filters should be required for the service of {provider}" do |provider|
  assert provider.default_service.referrer_filters_required?
end

Then "referrer filters should not be required for the service of {provider}" do |provider|
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
  stub_request(:post, backend_application_url(application, '/referrer_filters.xml'))
    .to_return(status: 201, body: %(<referrer_filter value="#{value}"/>))
end

def fake_application_referrer_filter_creation_error(application)
  stub_request(:post, backend_application_url(application, '/referrer_filters.xml'))
    .to_return(status: 422, body: %(<error>referrer filter can't be blank</error>))
end

def fake_application_referrer_filter_deletion(application, value)
  stub_request(:post, backend_application_url(application, "/referrer_filters/#{value}.xml?provider_key=#{application.provider_account.api_key}&service_id=#{application.service.backend_id}"))
    .to_return(status: 200, body: '')
end
