Then /^on (.*), me and "([^\"]+)" should get email about payment problem$/ do |date, provider|
  reset_mailer
  time_flies_to(date)
  assert_equal(1, unread_emails_for(nil).count { |m| m.subject =~ Regexp.new(Regexp.escape("Problem with payment")) })
  assert_equal(1, unread_emails_for(provider).count { |m| m.subject =~ Regexp.new(Regexp.escape("payment has failed")) })
end
