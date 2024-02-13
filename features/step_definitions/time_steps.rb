# frozen_string_literal: true

When '(I )wait a moment' do
  wait_for_requests
end

Given "it's the beginning of the month" do
  time_machine(Time.zone.now.at_beginning_of_month)
end
