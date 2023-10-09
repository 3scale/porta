# frozen_string_literal: true

#TODO: does this step belong to extra_field steps
Given "{buyer} has application {string} with extra fields:" do |buyer, app_name, table|
  plan = buyer.provider_account.first_service!.plans.default or raise 'Provider has no default application plan'
  cinstance = FactoryBot.build(:cinstance, { :user_account => buyer, :plan => plan,
                              :name => app_name, :description => app_name })
  cinstance.extra_fields = table.hashes.first
  cinstance.save!
end

Given "{buyer} has application {string} with plan {string}" do |buyer, name, plan_name|
  plan = ApplicationPlan.find_by!(name: plan_name)
  assert buyer.provider_account.application_plans.include?(plan)
  FactoryBot.create(:cinstance, :user_account => buyer,
                    plan:  plan,
                    name:  name)
end

Given "{buyer} has (an )application {string}" do |buyer, name|
  plan = buyer.provider_account.first_service!.application_plans.default or raise 'Provider has no default application plan'
  FactoryBot.create(:cinstance, user_account: buyer,
                                plan: plan,
                                name: name,
                                description: 'Blah blah')
end

Given "{buyer} has application {string} with description {string}" do |buyer, name, description|
  plan = buyer.provider_account.first_service!.application_plans.default or raise 'Provider has no default application plan'
  FactoryBot.create(:cinstance, :user_account => buyer,
                      :plan         => plan,
                      :name         => name,
                      :description  => description)
end

Given "{buyer} has application {string} with ID {string}" do |buyer, name, id|
  plan = buyer.provider_account.first_service!.application_plans.default
  FactoryBot.create(:cinstance, :application_id => id,
                      :user_account   => buyer,
                      :plan           => plan,
                      :name           => name,
                      :description    => 'Blah blah')
end

Given "{buyer} has no applications" do |buyer|
  buyer.bought_cinstances.destroy_all
end

Given "{buyer} has the following applications:" do |buyer, table|
  plan = buyer.provider_account.first_service!.plans.default

  table.map_headers! { |header| header.downcase.gsub(/\s+/, '_') }
  table.hashes.each do |hash|
    attributes = hash.symbolize_keys!.slice!(:state)

    cinstance = FactoryBot.build(:cinstance, attributes.merge(:user_account => buyer, :plan => plan))
    cinstance.description = 'Blah blah' if cinstance.description.blank?
    cinstance.save!

    cinstance.update_attribute(:state,  hash[:state]) if hash[:state]
  end

end

Given "{buyer} has {int} application(s)" do |buyer, number|
  plan = buyer.provider_account.first_service!.plans.default

  buyer.bought_cinstances.destroy_all

  number.to_i.times do |index|
    FactoryBot.create(:cinstance, :user_account => buyer,
                        plan:         plan,
                        name:         "App #{index + 1}",
                        description:  "Yet another app",
                        created_at: (number.to_i-index).seconds.ago) #Ensure applications are not created at the same second
  end
end

Given "the {provider} has the following applications:" do |provider, table|
  transform_applications_table(table)
  table.hashes.each do |row|
    assert provider.application_plans.include?(row[:plan]) if row[:plan]
    FactoryBot.create :cinstance, :user_account => row[:buyer],
                        :plan => row[:plan],
                        :name => row[:name],
                        :description => row[:description] || "Description"
  end
end

Given "{application} is suspended" do |application|
  application.suspend!
end

Given "{application} has extra field {string} blank" do |app, attr|
  app.update_attribute(:extra_fields, {attr => nil})
end

Given "{buyer} has no live applications" do |buyer|
  buyer.bought_cinstances.map &:suspend!
end

When "I follow {string} for {application}" do |label, application|
  step %(I follow "#{label}" within "#application_#{application.id}")
end

Then "{application} should be live" do |application|
  assert application.live?
end

Then "{application} should be suspended" do |application|
  assert application.suspended?
end

Then "I should see that {application} is {live_or_suspended}" do |application, state|
  step %(I should see "#{state}" within "#cinstance_state")
end

Then /^(.*) in the applications widget$/ do |action|
  within '#applications_widget' do
    step action
  end
end

Then /^I should see the following table in the applications widget:$/ do |table|
  table.diff!(extract_table('#applications_widget table', 'tr', 'th,td'))
end

Then /^I should see button to "(.*?)"$/ do | text |
  #assert has_xpath? "//input[@value = '#{text}']"
  assert has_xpath?("//button[contains(text(),'#{text}')]") || has_xpath?("//input[@value = '#{text}']")
end

Then /^I should not see button to "(.*?)"$/ do | text |
  assert has_no_xpath?("//button[contains(text(),'#{text}')]") || has_xpath?("//input[@value = '#{text}']")
end

Then /^I should see the app menu$/ do
  assert has_css?(selector_for('the secondary nav'))
end

Then /^I should see a list of available plans$/ do |table|
  table.hashes.each do |hash|
    assert page.has_css?('li a', :text => hash[:plan])
  end
end

When /^I click on Select this plan for the "([^"]*)" plan$/ do |plan|
  with_scope("div.select-plan-button[data-plan-name='#{plan}']") do
    page.find_link('Select this plan', visible: true)
    click_link('Select this plan', visible: true)
  end
end

When "I request to change to {plan}" do |plan|
  step %(I press "Request Plan Change" within "div.plan-preview[data-plan-id='#{plan.id}']")
end

When "I follow the link to {application}" do |app|
  find(:xpath, "//a[@href='#{provider_admin_application_path(app)}']").click
end

And(/^has an application$/) do
  buyer_name = SecureRandom.uuid # Use Faker ? use FactoryBot.create to generate just he values?
  plan_name = SecureRandom.uuid

  step %{an application plan "#{plan_name}" of provider "#{@provider.internal_domain}"}
  step %{a buyer "#{buyer_name}" signed up to application plan "#{plan_name}"}

  @application = @provider.buyer_accounts.find_by!(org_name: buyer_name).bought_cinstance
end

Given(/^I'm on that application page$/) do
  click_on 'Dashboard'
  click_on 'API' # this is supposed to be the name of the service
  click_on 'Apps'
  assert @application, '@application is missing'
  click_on @application.name
end

When /^I create an application "([^"]*)" from the audience context/ do |name|
  visit path_to 'the provider new application page'
  fill_in_new_application_form(name: name)
  click_on 'Create application'
end

When /^I create an application "([^"]*)" from the account "([^"]*)" context/ do |name, account_name|
  visit path_to %(the account context create application page for "#{account_name}")
  fill_in_new_application_form(name: name)
  click_on 'Create application'
end

When /^I create an application "([^"]*)" from the product "([^"]*)" context/ do |name, service_name|
  visit path_to %(the product context create application page for "#{service_name}")
  fill_in_new_application_form(name: name)
  click_on 'Create application'
end

When 'I fill in the new application form' do
  fill_in_new_application_form
end

When 'I fill in the new application form for product {string}' do |service_name|
  fill_in_new_application_form(service_name: service_name)
end

When 'I fill in the new application form with extra fields:' do |table|
  fill_in_new_application_form
  table.hashes.each do |h|
    # step %(I fill in "#{hash[:field]}" with "#{hash[:value]}")
    fill_in_pf(h[:field], with: h[:value])
  end
end

When 'I should not be allowed to create more applications' do
  visit path_to 'the provider new application page'
  fill_in_new_application_form
  click_on 'Create application'
  assert has_content?('Access Denied')
end

When /^buyer "([^"]*)" should not be allowed to create more applications/ do |buyer_name|
  visit path_to %(the account context create application page for "#{buyer_name}")
  fill_in_new_application_form
  click_on 'Create application'
  assert has_content?('Access Denied')
end

When /^I should not be allowed to create more applications for product "([^"]*)"/ do |service_name|
  visit path_to %(the product context create application page for "#{service_name}")
  fill_in_new_application_form
  click_on 'Create application'
  assert has_content?('Access Denied')
end

When "a service {string} of {provider} with no service plans" do |service_name, provider|
  service = provider.services.create!(name: service_name)
  service.service_plans.destroy_all
end

When "I won't be able to select an application plan" do
  assert app_plan_select.has_css?('.pf-m-disabled')
end

Given "the owner of {application} has email {string}" do |app, email|
  app.account.admins.first.update_attribute(:email, email)
end

Given "the application will return an error when suspended" do
  Cinstance.any_instance.stubs(:suspend).returns(false).once
end

Given "the application will return an error when changing its plan" do
  Cinstance.any_instance.stubs(:change_plan).returns(false).once
end

Given "they are reviewing the buyer's application details" do
  visit provider_admin_application_path(@buyer.application_contracts.first)
end

def fill_in_new_application_form(name: 'My App', service_name: 'API')
  pf4_select_first(from: 'Account') if page.has_css?('.pf-c-form__label', text: 'Account')
  pf4_select(service_name, from: 'Product') if page.has_css?('.pf-c-form__label', text: 'Product')
  pf4_select_first(from: 'Application plan') unless app_plan_select.has_css?('.pf-m-disabled')
  fill_in_pf('Name', with: name)
  fill_in_pf('Description', with: 'This is some kind of application')
end

def app_plan_select
  find_pf_select('Application plan')
end

def fill_in_pf(label, with:)
  find('.pf-c-form__group-label', text: label).sibling('.pf-c-form__group-control')
                                              .find('input')
                                              .set(with)
end
