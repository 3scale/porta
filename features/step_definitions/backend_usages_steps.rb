# frozen_string_literal: true

Given "an admin wants to add an unaccessible backend" do
  @backend = @provider.backend_apis.create!(name: 'Deleted Backend', private_endpoint: 'https://foo')
  @backend.update!(state: 'deleted')

  visit new_admin_service_backend_usage_path(@provider.default_service)
end

Then "only accessible backends will be available" do
  assert_options_in_select('Backend', @backend.name)
end
