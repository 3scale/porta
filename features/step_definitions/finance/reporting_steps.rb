Then /^on (.*), me and "([^\"]+)" should get email about (\d{1})\.payment problem$/ do |date, provider,attempt|
  reset_mailer
  date = date.gsub(Regexp.union(%w[of st nd rd]), '')
  time_machine(Time.zone.parse(date))
  assert_equal Time.zone.parse(date).beginning_of_hour, Time.zone.now.beginning_of_hour
  access_user_sessions
  assert_equal(1, unread_emails_for(nil).count { |m| m.subject =~ Regexp.new(Regexp.escape("Problem with payment")) })
  assert_equal(1, unread_emails_for(provider).count { |m| m.subject =~ Regexp.new(Regexp.escape("User payment problem")) })
end
