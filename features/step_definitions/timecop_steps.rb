def access_user_sessions
  UserSession.where("revoked_at is null").each {|e| e.update_attribute(:accessed_at, Time.zone.now)}
end

Given /^the year is (\d+)$/ do |year|
  Timecop.travel(Time.zone.now.change(:year => year.to_i))
end

Given /^the (?:date|time) is (.*)$/ do |time|
  time = Time.zone.parse(time)
  Timecop.travel(time)
  access_user_sessions
end

Given(/^this happened (\d+) (hours|days?) ago$/) do |num, time_range|
  time = num.to_i.public_send(time_range).ago
  Timecop.travel(time)
  access_user_sessions
end

Given /^the current date is not conflicting in new year\'s boundaries$/ do
  step "the date is 15 March 2011"
end

When /^(\d+) (second|minute|hour|day|week|month|year)s? pass(?:es)?$/ do |amount, period|
  duration = amount.to_i.send(period.to_sym)
  time_machine(duration.from_now)
  access_user_sessions
end

When /^(?:the )?time flies to (.*)$/ do |date|
  date = date.gsub(Regexp.union(%w(of st nd rd)), '')
  time_machine(Time.zone.parse(date))
  step %(the date should be #{date})
  access_user_sessions
end

# Sufix 'on 5th July 2009'
#
Then /^(.+) on (\d+(?:th|st|nd|rd) \S* \d{4}(?: .*)?)$/ do |original, date|
  # this ensures billing actions are run
  step %(time flies to #{date})
  # and then we freeze the time
  Timecop.freeze(Time.zone.parse(date)) do
    step original.strip
  end
end

Then /^(.+) at (\d{2}:\d{2}:\d{2})$/ do |original, time|
  time = Time.zone.parse(time)

  Timecop.freeze(time) do
    step original.strip
  end
end

Then /^the (?:date|time) should be (.*)$/ do |time|
  # making the comparison at the beginning of hour instead of just using the timestamps as time is no longer frozen, we simply travel
  # if you really need full precision you should write another step
  assert_equal Time.zone.parse(time).beginning_of_hour, Time.zone.now.beginning_of_hour
end
