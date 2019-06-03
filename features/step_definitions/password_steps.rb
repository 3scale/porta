When /^(.*) in the request password reset form$/ do |action|
  within "form[action='#{provider_password_path}']" do
    step action
  end
end

Given /^no user exists with an email of "(.*)"$/ do |email|
  assert_nil User.find_by_email(email)
end

Then /^the password of (user "[^"]*") should not be "([^"]*)"$/ do |user, password|
  assert !user.authenticated?(password)
end

When /^I follow the link found in the password reset email send to "([^\"]*)"$/ do |email|
  visit_url_in_email(email, /Lost password recovery/)

end

When /^I follow the link found in the provider password reset email send to "([^\"]*)"$/ do |email|
  visit_url_in_email(email, /Password Recovery/)
end

def visit_url_in_email(email, subject)
  User.find_by_email!(email)

  message = open_email(email, :with_subject => subject)

  url = message.body.to_s.scan(/http.*/).first
  assert_not_nil url, 'URL not found in the email'

  visit url
end

Then 'I should see the password confirmation error' do
  %q{I should see error "doesn't match Password" for field "Password confirmation"}
end
