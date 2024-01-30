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

Given "{buyer} has no applications" do |buyer|
  buyer.bought_cinstances.destroy_all
end

Given "{application} user key is {string}" do |application, key|
  application.update_column(:user_key, key) # rubocop:disable Rails/SkipsModelValidations
end

Given "{application} has {int} key(s)" do |application, number|
  application.update!(application_keys: FactoryBot.create_list(:application_key, number))
end

Given "{application} has no keys" do |application|
  application.application_keys.destroy_all
end

Given "{product} {has} mandatory app key" do |product, mandatory|
  product.update!(mandatory_app_key: mandatory)
end

Given "{application} has the following key(s):" do |application, table|
  fake_application_keys(application, table.raw.map(&:first))
end

Given "{application} has a trial period of {int} day(s)"  do |application, days|
  application.trial_period_expires_at = Time.zone.now + days.to_i.days
  application.save!
end

Given "{application} uses plan {string}" do |application, name|
  plan = application.issuer.plans.find_by!(name: 'Free')
  application.change_plan!(plan)
end

Given "{application} uses a custom plan" do |app|
  app.customize_plan!
end

Given "{buyer} has email {string}" do |buyer, email|
  buyer.admins.first.update!(email: email)
end

Given "the application will return an error when suspended" do
  Cinstance.any_instance.stubs(:suspend).returns(false).once
end

Given "the application will return an error when changing its plan" do
  Cinstance.any_instance.stubs(:change_plan).returns(false).once
end

Given "{application} is suspended" do |application|
  application.suspend!
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

Given "{application} has user key {string}" do |application, key|
  application.update!(user_key: key)
end

When "(they )delete the referrer filter {string}" do |value|
  find('tr td', text: value).sibling('td')
                            .click_button('Delete')
end

When /^I change the app plan to "([^"]*)"$/ do |plan|
  pf4_select(plan, from: 'Change plan')
  click_button 'Change'
end

When "(they )delete application key {string}" do |key|
  find("tr#application_key_#{key}").click_button("Delete")
end

Then "should see {application} stats" do |application|
  assert has_content?("Traffic statistics for #{@application.name}")
end

Then "(any of )the application keys {can} be deleted" do |deleteable|
  rows = find_all('#application_keys table tr.key')
  assert rows.all? do |row|
    row.has_css?('.delete_key', visible: deleteable, wait: 0)
  end
end

Then "there are/is {int} key(s)" do |keys|
  wait_for_requests
  assert_equal keys, find_all('tr.key').size
end

Then "there should not be a button to delete key {string}" do |key|
  assert find("tr#application_key_#{key}").has_no_button?('Delete')
end

And "{application}'s user key has not changed" do |application|
  old = application.user_key
  assert_equal old, application.reload.user_key
end
