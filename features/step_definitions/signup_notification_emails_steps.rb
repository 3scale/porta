# frozen_string_literal: true

When "{string} opens the account activation email" do |address|
  step %("#{address}" opens the email with subject "foo.3scale.localhost API account confirmation")
end

Then "{string} should receive the default account activation email" do |address|
  step %("#{address}" opens the account activation email)
  current_email.body =~ /Thank you for signing up for access to the .* API/
end

Then "{string} should receive the default account activation email with viral footer applyed" do | address |
  step %("#{address}" should receive the default account activation email)
  assert_match ThreeScale::EmailEngagementFooter.engagement_footer, current_email.body.to_s
end
