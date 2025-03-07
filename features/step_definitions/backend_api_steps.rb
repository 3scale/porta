# frozen_string_literal: true

Given "{provider} has the following backend( api):" do |provider, table|
  opts = transform_backend_apis_table(table).rows_hash
  @backend = FactoryBot.create(:backend_api, account: provider, **opts)
end

When "an admin is reviewing backend apis index page" do
  visit provider_admin_backend_apis_path
end

Given "an admin is at a backend api edit page" do
  @backend = @provider.backend_apis.create!(name: 'My Backend', private_endpoint: 'https://foo')
  visit edit_provider_admin_backend_api_path(@backend)
end

Then "they will be able to edit the name, description and base url" do
  fill_in_backend_api_form(name: 'Edited', description: 'Edited', url: 'http://edited.example.com')
end

When "they will not be able to update it without a name" do
  fill_in_backend_api_form(name: '')
  click_on 'Update Backend'
  assert_equal edit_provider_admin_backend_api_path(@backend), current_path
end

When "they will not be able to update it without a valid url" do
  fill_in_backend_api_form(url: '')
  click_on 'Update Backend'

  fill_in_backend_api_form(url: '%')
  click_on 'Update Backend'
  assert_content 'Backend could not be updated'
end

Then "they will be able to update it with an existing name and url" do
  first_backend = BackendApi.first
  last_backend = BackendApi.last
  assert_not_equal first_backend.name, last_backend.name
  assert_not_equal first_backend.private_endpoint, last_backend.private_endpoint

  visit edit_provider_admin_backend_api_path(last_backend)
  fill_in_backend_api_form( name: first_backend.name, url: first_backend.private_endpoint)
  assert_updated
end

Given "{backend} is used by {product}" do |backend, product|
  configs = product.backend_api_configs
  configs.create!(backend_api: backend, path: "/my_product") if configs.find_by(backend_api_id: backend.id).nil?
end

When "an admin tries to delete the backend api from its edit page" do
  visit edit_provider_admin_backend_api_path(@backend)
end

Then "it {is} possible to delete the backend" do |deleteable|
  if deleteable
    accept_confirm do
      click_link('a', text: "I understand the consequences, proceed to delete '#{@backend.name}' backend")
    end
    assert_content 'Backend will be deleted shortly'
  else
    assert_selector('p', text: 'The following products are using this backend:')
  end
end

Given /^a backend(?: "(.*)")?$/ do |name|
  @backend = @provider.backend_apis.create!(name: name || 'My Backend', private_endpoint: 'https://foo')
end

When "an admin is in the backend overview page" do
  visit provider_admin_backend_api_path(@backend)
end

Then "there is a list of all products using it" do
  within products_used_table do
    @backend.services.pluck(:name) do |name|
      should have_css('[data-label="Name"]', text: name)
    end
  end
end

And "the product becomes inaccessible" do
  @product.update!(state: 'deleted')
end

Then "the product is not in the list of all products using it" do
  assert @product.reload
  within products_used_table do
    should_not have_css('[data-label="Name"]', text: @product.name)
  end
end

And '{backend} is unavailable' do |backend|
  backend.update!(state: 'deleted')
end

def products_used_table
  find('#products-used-list-container')
end

def assert_created
  click_on 'Create Backend'
  assert_content 'Backend created'
end

def assert_not_created(error: nil)
  click_on 'Create Backend'
  assert_content 'Backend could not be created'
  assert_selector('p.inline-errors', text: error) if error
end

def assert_updated
  click_on 'Update Backend'
  assert_content 'Backend updated'
end

def fill_in_backend_api_form(name: 'My Backend', system_name: 'my_backend', description: 'Description...', url: 'http://api.example.com')
  fill_in('Name', with: name)
  fill_in('System name', with: system_name) unless find('input[name$="[system_name]"]').disabled?
  fill_in('Description', with: description)
  fill_in('Private Base URL', with: url)
end
