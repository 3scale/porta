# frozen_string_literal: true

# Example:
#
#   Given a provider
#   And a buyer "Bob"
#   And a product "My API"
#   And the following application plan:
#      | Product | Name  |
#      | My API  | Basic |
#   And the following applications:
#     | Buyer | Product | Name       | Plan  |
#     | Jane  |         | Jane's app | Basic |
#     |       | My API  | Jane's app | Basic |
#     | Jane  | My API  | Jane's app |       |
#
Given "the following application(s):" do |table|
  transform_applications_table(table)
  table.hashes.each do |options|
    service = options[:service] || options[:user_account].provider_account.first_service!
    options[:plan] ||= service.default_application_plan || service.plans.first or raise 'Provider has no default application plan'

    @application = FactoryBot.create(:application, **options)
  end
end

Given "{application} user key is {string}" do |application, key|
  application.update_column(:user_key, key) # rubocop:disable Rails/SkipsModelValidations
end

Given "{application} has {amount} key(s)" do |application, amount|
  if amount.positive?
    FactoryBot.create_list(:application_key, amount, application: application)
  else
    application.application_keys.destroy_all
  end
end

Given "{application} has the following key(s):" do |application, table|
  fake_application_keys(application, table.raw.map(&:first))
end

Given "{application} has a trial period of {int} day(s)"  do |application, days|
  application.trial_period_expires_at = Time.zone.now + days.to_i.days
  application.save!
end

Given "{application} uses a custom plan" do |app|
  app.customize_plan!
end

Given "the application will return an error when suspended" do
  Cinstance.any_instance.stubs(:suspend).returns(false).once
end

Given "the application will return an error when changing its plan" do
  Cinstance.any_instance.stubs(:change_plan).returns(false).once
end

Given "{application} is suspended" do |application|
  application.suspend! unless application.suspended?
end

# Given the application has the following extra fields:
#   | Engine       | 120 hp |
#   | Wheels       | 4      |
Given "{application} has the following extra fields:" do |app, table|
  parameterize_headers(table)
  app.reload.update!(extra_fields: table.rows_hash)
end

Given "{application} has the following referrer filters:" do |application, table|
  table.raw.map do |row|
    FactoryBot.create(:referrer_filter, application: application, value: row.first)
  end
end

Given "{application} can't have more referrer filters" do |application|
  FactoryBot.create_list(:referrer_filter, application.filters_limit, application: application)
end

Given "the backend will create key {string} for {application}" do |key, application|
  stub_request(:post, backend_application_url(application, '/keys.xml'))
    .to_return(status: fake_status(201), body: %(<key value="#{key}"/>))
  fake_application_keys(application, [key])
end

Then "there are/is {int} key(s)" do |keys|
  assert_equal keys, find_all('tr.key').size
end

Then "new applications with {plan} will be pending for approval" do |plan|
  assert Cinstance.create(user_account: current_account, plan: plan).pending?
end

And "{application} user key should( still) be {string}" do |application, key|
  assert_equal key, application.reload.user_key
end
