# frozen_string_literal: true

Then "the global jQuery version should be {string}" do |major|
  version = page.evaluate_script("jQuery.fn.jquery")
  expect(version).to start_with(major), "Expected global jQuery #{major}.x but got #{version}"
end
