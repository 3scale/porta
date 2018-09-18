# frozen_string_literal: true

And(/^there are no events$/) do
  EventStore::Repository.adapter.delete_all
end

And(/^there should be (\d+) application cancelled event$/) do |n|
  cancelled = EventStore::Repository.adapter.where(event_type: Cinstances::CinstanceCancellationEvent)

  assert_equal n.to_i, cancelled.count
end

And(/^there should be (\d+) valid service contract cancelled event$/) do |count|
  check_events_validity!(type: ServiceContracts::ServiceContractCancellationEvent, count: count)
end

And(/^there should be (\d+) valid service contract created event$/) do |count|
  check_events_validity!(type: ServiceContracts::ServiceContractCreatedEvent, count: count)
end

And(/^there should be (\d+) valid account created event$/) do |count|
  check_events_validity!(type: Accounts::AccountCreatedEvent, count: count)
end

And(/^there should be (\d+) valid account deleted event$/) do |count|
  check_events_validity!(type: Accounts::AccountDeletedEvent, count: count)
end

And(/^there should be (\d+) valid application created event$/) do |count|
  check_events_validity!(type: Applications::ApplicationCreatedEvent, count: count)
end

And(/^there should be (\d+) valid cinstance cancellation event$/) do |count|
  check_events_validity!(type: Cinstances::CinstanceCancellationEvent, count: count)
end

And(/^all the events should be valid$/) do
  assert EventStore::Repository.adapter.all.all? { |event| event.attributes && event.valid? }, 'all the events are not valid'
end
