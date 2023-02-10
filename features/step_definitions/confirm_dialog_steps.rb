# frozen_string_literal: true

Then /^(.+) and I confirm dialog box(?: "(.*)")?$/ do |original, text|
  if rack_test?
    step original
  else
    accept_confirm(text) do
      step original
    end
    wait_for_requests
  end
end
