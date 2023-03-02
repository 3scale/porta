Given(/^a provider has a developer "(.*?)" with an application name "(.*?)"$/) do |developer_name, developer_app_name|
  steps %{
    Given a provider "foo.3scale.localhost"
    And an application plan "Default" of provider "foo.3scale.localhost"
    And a buyer "#{developer_name}" signed up to provider "foo.3scale.localhost"
    And buyer "#{developer_name}" has application "#{developer_app_name}"
  }
end

When(/^the provider is logged in and visits the "(.*?)" application stats$/) do |developer_app_name|
  steps %q{
    Given current domain is the admin domain of provider "foo.3scale.localhost"
    And I log in as provider "foo.3scale.localhost"
  }

  click_on(text: /\d Applications?/i, match: :first)

  within '.cinstances' do
    click_on developer_app_name, match: :one
  end

  assert_text "Application '#{developer_app_name}'"

  within('ul.subsubmenu') do
    click_on 'Analytics', match: :one
  end

  assert_text "Traffic statistics for #{developer_app_name}"
end

Given(/^buyer "(.*?)" made (\d+) service transactions (\d+) hours ago:$/) do |developer_name, transactions_number, hours, table|
  travel_to(hours.hours.ago)
  access_user_sessions
  step %'buyer "#{developer_name}" makes #{transactions_number} service transactions with:', table
end
