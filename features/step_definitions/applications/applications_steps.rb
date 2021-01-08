# frozen_string_literal: true

#TODO: does this step belong to extra_field steps
Given "{buyer} has application {string} with extra fields" do |buyer, app_name, table|
  plan = buyer.provider_account.first_service!.plans.default or raise 'Provider has no default application plan'
  cinstance = FactoryBot.build(:cinstance, user_account: buyer,
                                           plan: plan,
                                           name: app_name,
                                           description: app_name)
  cinstance.extra_fields = table.hashes.first
  cinstance.save!
end

Given "{buyer} has application {string} with description {string}" do |buyer, name, description|
  plan = buyer.provider_account.first_service!.application_plans.default or raise 'Provider has no default application plan'
  FactoryBot.create(:cinstance, user_account: buyer,
                                plan: plan,
                                name: name,
                                description: description)
end

Given "buyer {string} has application {string}" do |buyer_name, application_name|
  step %(buyer "#{buyer_name}" has application "#{application_name}" with description "Blah blah")
end

Given "{buyer} has applicatoin {string} with ID {string}" do |buyer, name, id|
  plan = buyer.provider_account.first_service!.application_plans.default
  FactoryBot.create(:cinstance, application_id: id,
                                user_account: buyer,
                                plan: plan,
                                name: name,
                                description: 'Blah blah')
end

Given "{buyer} has no applications" do |buyer|
  buyer.bought_cinstances.destroy_all
end

Given "{buyer} has the following applications" do |buyer, table|
  plan = buyer.provider_account.first_service!.plans.default

  table.map_headers! { |header| header.downcase.gsub(/\s+/, '_') }
  table.hashes.each do |hash|
    attributes = hash.slice!(:state)

    cinstance = FactoryBot.build(:cinstance, attributes.merge(user_account: buyer, plan: plan))
    cinstance.description = 'Blah blah' if cinstance.description.blank?
    cinstance.save!

    cinstance.update!(state: hash[:state]) if hash[:state]
  end

end

Given "{buyer} has {int} applications" do |buyer, number|
  plan = buyer.provider_account.first_service!.plans.default

  buyer.bought_cinstances.destroy_all

  number.to_i.times do |index|
    FactoryBot.create(:cinstance, user_account: buyer,
                                  plan: plan,
                                  name: "App #{index + 1}",
                                  description: 'Yet another app')
  end
end

Given "the {provider} has the following applications" do |provider, table|
  table.hashes.each do |row|
    assert provider.application_plans.include?(row[:plan]) if row[:plan]
    FactoryBot.create :cinstance, user_account: row[:buyer],
                                  plan: row[:plan],
                                  name: row[:name],
                                  description: row[:description] || 'Description'
  end
end

Given "{application} is suspended" do |application|
  application.suspend!
end

Given "{application} has extra field {string} blank" do |app, attr|
  app.update!(extra_fields: { attr => nil })
end

Given "{buyer} has no live applications" do |buyer|
  buyer.bought_cinstances.map(&:suspend!)
end

When "I follow {string} for {application}" do |label, application|
  step %(I follow "#{label}" within "#application_#{application.id}")
end

When "I follow {string} in the applications widget" do |label|
  step %(I follow "#{label}" within "#applications_widget")
end

Then "{application} should be live" do |application|
  assert application.live?
end

Then "{application} should be suspended" do |application|
  assert application.suspended?
end

Then "I should see that {application} is {live_state}" do |application, state|
  step %(I should see "#{state}" within "#cinstance_state")
end

Then /^(.*) in the applications widget$/ do |action|
  within '#applications_widget' do
    step action
  end
end

Then "I should see the following table in the applications widget:" do |table|
  table.diff!(extract_table('#applications_widget table', 'tr', 'th,td'))
end

Then "I should see application named {string} in the applications table" do |name|
  assert_select 'table#applications' do
    assert_select 'tr th', name
  end
end

Then "I should see button to {string}" do |text|
  assert has_xpath(find(:button, text: text) || "//input[@value = '#{text}']")
end

Then "I should not see button to {string}" do |text|
  assert has_no_xpath(find(:button, text: text) || "//input[@value = '#{text}']")
end

Then "I should see the app menu" do
  assert has_xpath?("//ul[@id='subsubmenu']") || has_xpath?("//ul[@class='subsubmenu']")
end

Then "I should not see the applications widget" do
  assert has_no_xpath?('//div[@id="applications_widget"]')
end

Then "I should see a list of available plans" do |table|
  table.hashes.each do |hash|
    assert page.has_css?('li a', text: hash[:plan])
  end
end

When "I click on Select this plan for the {string} plan" do |plan|
  with_scope "div.select-plan-button[data-plan-name='#{plan}']" do
    page.find_link('Select this plan', visible: true)
    click_link('Select this plan', visible: true)
  end
end

When "I request to change to {plan}" do |plan|
  plan = Plan.find_by!(name: plan)
  step %(I press "Request Plan Change" within "div.plan-preview[data-plan-id='#{plan.id}']")
end

When "I follow the link to {application}" do |app|
  find(:xpath, "//a[@href='#{admin_service_application_path(app.service, app)}']").click
end

And "has an application" do
  buyer_name = SecureRandom.uuid # Use Faker ? use FactoryBot.create to generate just he values?
  plan_name = SecureRandom.uuid

  step %(an application plan "#{plan_name}" of provider "#{@provider.domain}")
  step %(a buyer "#{buyer_name}" signed up to application plan "#{plan_name}")

  @application = Account.find_by!(org_name: buyer_name).bought_cinstance
end

Given "I'm on that application page" do
  click_on 'Dashboard'
  click_on 'API' # this is supposed to be the name of the service
  click_on 'Apps'
  assert @application, '@application is missing'
  click_on @application.name
end
