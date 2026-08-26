# frozen_string_literal: true

Given "{provider} has plans ready for signups" do |provider|
  FactoryBot.create(:published_application_plan, name: 'application_plan', issuer: provider.first_service!, default: true)
end

When /^I fill in the invitation signup as "([^"]*)"$/ do |username|
  fill_in("Username", :with => username)
  fill_in("Password", :with => "superSecret1234#")
  fill_in("Password confirmation", :with => "superSecret1234#")
  click_button "Sign up"
end

When /^I fill in the signup fields as "([^"]*)"$/ do |name|
  fill_in_signup_fields_as(name)
end

def fill_in_signup_fields_as(name)
  fill_in('Username', with: name)
  fill_in('Email', with: "#{name}@3scale.localhost")
  fill_in('Organization/Group Name', with: "#{name}'s stuff")
  fill_in('Password', with: 'superSecret1234#')
  fill_in('Password confirmation', with: 'superSecret1234#')

  click_on 'Sign up'
end

When /^I fill in the invalid signup fields( in a non-suspicious way)?$/ do |non_suspicious|
  pass_time(15, 'seconds') if non_suspicious
  fill_in('Email', with: 'invalid email')
  click_button 'Sign up'
end

When /^(?:I|someone) (?:signup|signs up) with the email "([^"]*)"$/ do |email|
  visit signup_path
  fill_in "Username", :with => email.gsub(/[^\w]/, '-')
  fill_in "Email", :with => email
  fill_in "Organization/Group Name", :with => email.gsub(/[^\w]/, '-')
  fill_in "Password", :with => "superSecret1234#"
  fill_in "Password confirmation", :with => "superSecret1234#"
  click_button "Sign up"
end

Then /^I should see the signup page$/ do
  assert has_xpath?("//form[@id='signup_form']")
end

Then /^I should see the registration succeeded$/ do
  assert has_content? "Thank you"
end

When /^I have a cas token in my session$/ do
  res = stub :body => "yes\nlaurie", :code => 200
  HTTPClient.expects(:get).with(anything).returns(res)

  page.driver.get '/session/create?ticket=token'
end

When /^I fill and send the missing data for the signup page$/ do
  assert_current_path signup_path
  fill_in('Organization/Group Name', with: 'Planet eXpress')
  click_button 'Sign up'
end

def password_field
  "input[type=password]"
end

Then /^I should see the password field$/ do
  should have_selector(password_field)
end

Then /^I should not see the password field$/ do
  should_not have_selector(password_field)
end

module ReadonlyField
  module_function

  def readonly_field(locator)
    xpath = descendant(:input)[attr(:readonly)] # rubocop:disable Style/Attr
    locate_field(xpath, locator)
  end
end
