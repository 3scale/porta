# frozen_string_literal: true

And "there are no events" do
  EventStore::Repository.adapter.delete_all
end

And "there should be 1 application cancelled event" do
  cancelled = EventStore::Repository.adapter.where(event_type: Cinstances::CinstanceCancellationEvent)

  assert_equal 1, cancelled.count
end

And "there should be {int} valid service contract cancelled event(s)" do |count|
  check_events_validity!(type: ServiceContracts::ServiceContractCancellationEvent, count: count)
end

And "there should be {int} valid service contract created event(s)" do |count|
  check_events_validity!(type: ServiceContracts::ServiceContractCreatedEvent, count: count)
end

And "there should be {int} valid account created event(s)" do |count|
  check_events_validity!(type: Accounts::AccountCreatedEvent, count: count)
end

And "there should be {int} valid account deleted event(s)" do |count|
  check_events_validity!(type: Accounts::AccountDeletedEvent, count: count)
end

And "there should be {int} valid application created event(s)" do |count|
  check_events_validity!(type: Applications::ApplicationCreatedEvent, count: count)
end

And "there should be {int} valid cinstance cancellation event(s)" do |count|
  check_events_validity!(type: Cinstances::CinstanceCancellationEvent, count: count)
end

And "all the events should be valid" do
  assert EventStore::Repository.adapter.all.all? { |event| event.attributes && event.valid? }, 'all the events are not valid'
end
