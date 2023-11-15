# frozen_string_literal: true

Given "{provider} has plans (already )ready for signups" do |provider|
  create_plan(:application, name: 'application_plan', issuer: provider, published: true, default: true)
end

When /^I fill in the invitation signup with email "([^"]*)"$/ do | email |
  fill_in("Email", :with => email)
  step %(I fill in the invitation signup as "#{email}")
end

When /^I fill in the invitation signup as "([^"]*)"$/ do |username|
  fill_in("Username", :with => username)
  fill_in("Password", :with => "supersecret")
  fill_in("Password confirmation", :with => "supersecret")
  click_button "Sign up"
end

When /^I fill in the signup fields as "([^"]*)"$/ do |name|
  fill_in('Username', with: name)
  fill_in('Email', with: "#{name}@3scale.localhost")
  fill_in('Organization/Group Name', with: "#{name}'s stuff")
  fill_in('Password', with: 'supersecret')
  fill_in('Password confirmation', with: 'supersecret')

  click_on 'Sign up'
end

When /^I fill in the invalid signup fields( in a non-suspicious way)?$/ do |non_suspicious|
  step %(15 seconds pass) if non_suspicious
  step %(I fill in "Email" with "invalid email")
  step %(I press "Sign up")
end

When /^(?:I|someone) (?:signup|signs up) with the email "([^"]*)"$/ do |email|
  step "I go to the sign up page"
  fill_in "Username", :with => email.gsub(/[^\w]/, '-')
  fill_in "Email", :with => email
  fill_in "Organization/Group Name", :with => email.gsub(/[^\w]/, '-')
  fill_in "Password", :with => "supersecret"
  fill_in "Password confirmation", :with => "supersecret"
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
  steps <<-GHERKIN
    Then I should be at url for the signup page
    When I fill in the following:
      | Organization/Group Name | Planet eXpress |
    And I press "Sign up"
  GHERKIN
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

Then "the buyer {will} need to pass the captcha after signup form is filled in {how}" do |will, how|
  fill_in("Email", with: "Invalid email") if how == 'wrong'
  fill_in('Email', with: "user@3scale.localhost") unless how == 'wrong'
  check_hidden_honeypot if how == 'suspiciously'
  fill_in('Username', with: name)
  fill_in('Organization/Group Name', with: "User stuff")
  fill_in('Password', with: 'supersecret')
  fill_in('Password confirmation', with: 'supersecret')
  click_on 'Sign up'
  page.should have_selector(RECAPTCHA_SCRIPT, visible: false) if will
  page.should_not have_selector(RECAPTCHA_SCRIPT, visible: false) unless will
end

def check_hidden_honeypot
  id = find("input[name*='confirmation'][type=checkbox]", visible: :hidden)[:id]
  page.evaluate_script <<-JS
    document.getElementById("#{id}").checked = true
  JS
end