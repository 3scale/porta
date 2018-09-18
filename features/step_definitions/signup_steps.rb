Given /^(provider "[^"]*") conditions to allow signup are met$/ do |provider|
  step %{provider "#{provider.org_name}" has multiple applications enabled}
  #only one of these conditions seems to suffice, but we are using both (review!)
  provider.first_service!.plans.create!(:name => 'Provider plan')
end

Given /^provider "([^"]*)" has plans already ready for signups$/ do |org_name|
  step %{a default service of provider "#{org_name}" has name "api"}
  step %{a account plan "account_plan" of provider "#{org_name}"}
  step %{a service plan "service_plan" for service "api" exists}
  step %{an application plan "application_plan" of service "api"}

  step %{service plan "service_plan" is default}
  step %{account plan "account_plan" is default}
  step %{application plan "application_plan" is default}
end

When /^I fill in all required signup fields as "([^\"]*)"$/ do |buyer_name|
  step %(I fill in "Username" with "#{buyer_name}")
  step %(I fill in "Email" with "#{buyer_name}@example.org")
  step %(I fill in "Password" with "supersecret")
  step %(I fill in "Password confirmation" with "supersecret")
  step %(I fill in "Organization/Group Name" with "#{buyer_name}")
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

When /^new provider "([^"]*)" signs up and activates$/ do |name|
  step %(I go to the sign up page for the "Free" plan)

  step %(I fill in "Email" with "bugs@acme.com")
  step %(I fill in "Username" with "#{name}")
  step %(I fill in "Organization/Group Name" with "#{name}")

  step %(I fill in "Password" with "supersecret")
  step %(I fill in "Password confirmation" with "supersecret")
  step %(I press "Sign up")

  assert_not_nil User.find_by_username(name)

  step %(user "#{name}" activates himself)
end

When /^I fill in the signup fields as "([^\"]*)"$/ do |name|
  step %(I fill in "Username" with "#{name}")
  step %(I fill in "Email" with "#{name}@example.com")
  step %(I fill in "Organization/Group Name" with "#{name}'s stuff")
  step %(I fill in "Password" with "supersecret")
  step %(I fill in "Password confirmation" with "supersecret")
  step %(I press "Sign up")
end

When /^I fill in the invalid signup fields$/ do
  step %(I fill in "Email" with "invalid email")
  step %(I press "Sign up")
end

When /^I complete the signup process$/ do
  step %{I fill in the signup fields as "bob"}
end

When /^I request the url of the signup page$/ do
  visit '/signup'
end

Then /^I should see the application plans selection$/ do
  step %{I should see "Plans"}
end

When /^I select the "([^"]*)" application plan$/ do |plan|
  pending
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
  assert has_xpath?("//input[@value='Sign up']")
end

Then /^I should not see the signup page$/ do
  response.should_not have_text /Sign up/
end

#FIXME
Then /^"([^\"]*)" should receive an email to activate the account$/ do |email_address|
  # pending
  # step %{"#{email_address}" should receive an email with subject "Please confirm your email"}
end

Then /^I should see the registration succeeded$/ do
  assert has_content? "Thank you"
end

When /^I have a janrain token in my session$/ do
  valid_json = '{"stat": "ok", "profile": {"identifier": "http://somegoogleprofile.com"}}'
  FakeWeb.register_uri(
    :get, "https://rpxnow.com/api/v2/auth_info?token=token&apiKey=",
    :status => [200, 'OK'],
    :body => valid_json)

  page.driver.post '/session/janrain?token=token'
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
  include XPath::HTML
  extend self

  def readonly_field(locator)
    xpath = descendant(:input)[attr(:readonly)] # rubocop:disable Style/Attr
    locate_field(xpath, locator)
  end
end

Then(/^I should see a correct and un-editable admin portal subdomain$/) do
  portal = ReadonlyField.readonly_field('Admin Portal')
  should have_xpath portal
  assert_equal 'hello-monster-admin', find(:xpath, portal).value
end
