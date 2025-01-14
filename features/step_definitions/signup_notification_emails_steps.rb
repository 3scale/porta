When /^"([^\"]*)" opens the account activation email$/ do |address|
  open_email(address, with_subject: 'foo.3scale.localhost API account confirmation')
end

Then /^"([^\"]*)" should receive the default account activation email$/ do |address|
  open_email(address, with_subject: 'foo.3scale.localhost API account confirmation')
  current_email.body =~ /Thank you for signing up for access to the .* API/
end

Then(/^"(.*?)" should receive the default account activation email with viral footer applied$/) do | address |
  open_email(address, with_subject: 'foo.3scale.localhost API account confirmation')
  current_email.body =~ /Thank you for signing up for access to the .* API/
  assert_match ThreeScale::EmailEngagementFooter.engagement_footer, current_email.body.to_s
end

