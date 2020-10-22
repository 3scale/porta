# frozen_string_literal: true

Then "on {}, me and {string} should get email about {int}.payment problem" do |date, provider, attempt|
  step %(a clear email queue)
  step %(time flies to #{date})
  step %(I should receive an email with subject "Problem with payment")
  step %("#{provider}" should receive an email with subject "User payment problem")
end
