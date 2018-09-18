Then /^on (.*), me and "([^\"]+)" should get email about (\d{1})\.payment problem$/ do |date, provider,attempt|
  step %(a clear email queue)
  step %(time flies to #{date})
  step %(I should receive an email with subject "Problem with payment")
  step %("#{provider}" should receive an email with subject "User payment problem")
end
