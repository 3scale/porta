# frozen_string_literal: true

After do
  Time.zone = Rails.application.config.time_zone
  travel_back
end

# Wrapper for travel_to but implementing safe nested traveling
def safe_travel_to(time, &block)
  time_was_frozen = time_frozen?
  previous_time = Time.zone.now
  travel_back
  travel_to(time, &block)
ensure
  if block_given?
    time_was_frozen ? travel_to(previous_time) : travel_back
  end
end

def access_user_sessions
  UserSession.where('revoked_at is null').each { |session| session.update({ accessed_at: Time.zone.now }) }
end

Given /^the (?:date|time) is (.*)$/ do |time|
  time = Time.zone.parse(time)
  travel_to(time)
  access_user_sessions
end

When /^(\d+) (second|minute|hour|day|week|month|year)s? pass(?:es)?$/ do |amount, period|
  pass_time(amount, period)
end

def pass_time(amount, period)
  duration = amount.to_i.send(period.to_sym)
  time_machine(duration.from_now)
  access_user_sessions
end

When /^(?:the )?time flies to (.*)$/ do |date|
  date = date.gsub(Regexp.union(%w[of st nd rd]), '')
  time_machine(Time.zone.parse(date))
  assert_equal Time.zone.parse(date).beginning_of_hour, Time.zone.now.beginning_of_hour
  access_user_sessions
end

# Suffix 'on 5th July 2009'
# When '(without scheduled jobs)' is present, scheduled jobs will be skipped when travelling in time
Then /^(.+) on (\d+(?:th|st|nd|rd) \S* \d{4}(?: [^\(]*)?)( \(without scheduled jobs\))?$/ do |original, date, skip_jobs|
  unless skip_jobs
    date = date.gsub(Regexp.union(%w[of st nd rd]), '')
    time_machine(Time.zone.parse(date))
    assert_equal Time.zone.parse(date).beginning_of_hour, Time.zone.now.beginning_of_hour
    access_user_sessions
  end
  safe_travel_to(Time.zone.parse(date)) do
    step original.strip
  end
end

Then /^(.+) at (\d{2}:\d{2}:\d{2})$/ do |original, time|
  time = Time.zone.parse(time)

  safe_travel_to(time) do
    step original.strip
  end
end

Then /^the (?:date|time) should be (.*)$/ do |time|
  # making the comparison at the beginning of hour instead of just using the timestamps as time is no longer frozen, we simply travel
  # if you really need full precision you should write another step
  assert_equal Time.zone.parse(time).beginning_of_hour, Time.zone.now.beginning_of_hour
end
