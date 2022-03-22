# frozen_string_literal: true

Given 'a backend' do
  @backend = FactoryBot.create(:backend_api, name: 'My Backend', private_endpoint: 'https://foo', account: @provider)
end

Given 'a product' do
  @product = @provider.default_service
end

And 'a backend used by this product' do
  @backend = FactoryBot.create(:backend_api, name: 'My Backend', private_endpoint: 'https://foo', account: @provider)
  FactoryBot.create(:backend_api_config, backend_api: @backend, service: @product)
end

Given 'a backend that is unavailable' do
  @backend = @provider.backend_apis.create!(name: 'Deleted Backend', private_endpoint: 'https://foo')
  @backend.update!(state: 'deleted')
end

And "an admin is at a product's backend usages page" do
  @product = @provider.default_service
  visit admin_service_backend_usages_path(@product)
end

When "an admin goes to the product's backend usages page" do
  visit admin_service_backend_usages_path(@product)
end

Then 'they can add the backend by filling up the form' do
  click_on 'Add Backend'
  pf4_select(@backend.name, from: 'Backend')
  fill_in('Path', with: '/api/v1')
  click_on 'Add to Product'
end

And 'the product will be using this backend' do
  assert_includes @product.reload.backend_apis, @backend
end

When 'they try to add the backend( again)' do
  click_on 'Add Backend'
end

Then "the backend won't be available" do
  assert_select_not_inclues_option('Backend', @backend.name)
end

Then "they can't add the backend with an invalid path" do
  click_on 'Add Backend'
  pf4_select(@backend.name, from: 'Backend')
  fill_in('Path', with: '???')
  click_on 'Add to Product'

  assert_content "Couldn't add Backend to Product"
  assert_not_includes @product.reload.backend_apis, @backend
end
