# frozen_string_literal: true

When '(I )wait a moment' do
  wait_for_requests
  # FIXME: some ajax responses execute changes in a setTimeout and Cucumber don't wait the for them
  # e.g. Scenario: Adding a new item
end

Given "it's the beginning of the month" do
  time_machine(Time.zone.now.at_beginning_of_month)
end
