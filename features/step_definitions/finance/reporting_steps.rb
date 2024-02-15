Then /^on (.*), me and "([^\"]+)" should get email about (\d{1})\.payment problem$/ do |date, provider,attempt|
  reset_mailer
  time_flies_to(date)
  assert_equal(1, unread_emails_for(nil).count { |m| m.subject =~ Regexp.new(Regexp.escape("Problem with payment")) })
  assert_equal(1, unread_emails_for(provider).count { |m| m.subject =~ Regexp.new(Regexp.escape("User payment problem")) })
end
