# frozen_string_literal: true

# This is a hack used only for debugging.
When "I wait a moment" do
  wait_for_requests
end

When "I wait (for ){int} second(s)" do |seconds|
  sleep(seconds)
end
