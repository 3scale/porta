# frozen_string_literal: true

And 'the backend is unavailable' do
  @backend.update!(state: 'deleted')
end

When "an admin goes to the product's backend usages page" do
  visit admin_service_backend_usages_path(@product)
end

Then 'they can add the backend by filling up the form' do
  click_on_add_backend
  pf4_select(@backend.name, from: 'Backend')
  fill_in('Path', with: '/api/v1')
  click_on 'Add to product'
end

And 'the product will be using this backend' do
  assert_includes @product.reload.backend_apis, @backend
end

When 'they try to add the backend( again)' do
  click_on_add_backend
end

Then "the backend won't be available" do
  assert_select_not_inclues_option('Backend', @backend.name)
end

Then "they can't add the backend with an invalid path" do
  click_on_add_backend
  pf4_select(@backend.name, from: 'Backend')
  fill_in('Path', with: '???')
  click_on 'Add to product'

  assert_content "Couldn't add Backend to Product"
  assert_not_includes @product.reload.backend_apis, @backend
end

And "they can create a backend from there" do
  click_on I18n.t('api.backend_usages.index.empty_state.primary_action')
  assert_current_path new_admin_service_backend_usage_path(@product)
end

def click_on_add_backend
  click_on I18n.t('api.backend_usages.index.toolbar.primary')
end
