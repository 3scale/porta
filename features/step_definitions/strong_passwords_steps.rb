Given /^(provider "[^\"]*") is requiring strong passwords$/ do |provider|
  provider.settings.update_attribute :strong_passwords_enabled, true
end

Then /^I should see the error that the password is too weak$/ do
  assert has_content? User::STRONG_PASSWORD_FAIL_MSG
end
