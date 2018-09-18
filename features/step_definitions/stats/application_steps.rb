Given(/^a provider has a developer "(.*?)" with an application name "(.*?)"$/) do |developer_name, developer_app_name|
  steps %{
    Given a provider "foo.example.com"
    And an application plan "Default" of provider "foo.example.com"
    And a buyer "#{developer_name}" signed up to provider "foo.example.com"
    And buyer "#{developer_name}" has application "#{developer_app_name}"
  }
end

When(/^the provider is logged in and visits the "(.*?)" application stats$/) do |developer_app_name|
  steps %q{
    Given current domain is the admin domain of provider "foo.example.com"
    And I log in as provider "foo.example.com"
  }

  click_on 'Applications', match: :one

  within '.cinstances' do
    click_on developer_app_name, match: :one
  end

  assert_text "Application '#{developer_app_name}'"

  within('ul#subsubmenu') do
    click_on 'Analytics', match: :one
  end

  assert_text "Usage statistics for #{developer_app_name}"
end

Given(/^buyer "(.*?)" made (\d+) service transactions (\d+) hours ago:$/) do |developer_name, transactions_number, hours, table|
  step %'this happened #{hours} hours ago'
  step %'buyer "#{developer_name}" makes #{transactions_number} service transactions with:', table
end
