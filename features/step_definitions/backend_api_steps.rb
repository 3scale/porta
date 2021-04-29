# frozen_string_literal: true

Given /^a backend api "([^"]*)"( that is unnaccessible)?$/ do |name, unnaccessible|
  backend = @provider.backend_apis.create!(name: name, private_endpoint: 'https://foo')
  backend.update!(state: 'deleted') if unnaccessible.present?
end

Given(/^a backend api "([^"]*)" using the following products:$/) do |name, table|
  services = @provider.services
  backend = @provider.backend_apis.create!(name: name, private_endpoint: 'https://foo')

  table.raw.each do |row, i|
    service = services.find_by(name: row) || services.create!(name: row, mandatory_app_key: false)
    service.backend_api_configs.create!(backend_api: backend, path: "api/#{i}")
  end
end

Then(/^I should see the following products being used:$/) do |table|
  within products_used_table do
    table.raw.each do |row|
      should have_css('[data-label="Name"]', text: row[0])
    end
  end
end

Then(/^I should not see product "([^"]*)" being used$/) do |name|
  within products_used_table do
    should_not have_css('[data-label="Name"]', text: name)
  end
end

def products_used_table
  find('#products_using_backend')
end
