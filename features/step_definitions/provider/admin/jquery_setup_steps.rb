# frozen_string_literal: true

Then "the global jQuery version should be {string}" do |major|
  version = page.evaluate_script("jQuery.fn.jquery")
  expect(version).to start_with(major), "Expected global jQuery #{major}.x but got #{version}"
end

Then "window.jQuery1 should be available" do
  available = page.evaluate_script("typeof window.jQuery1 === 'function'")
  assert available, "window.jQuery1 is not available"
end

Then "window.jQuery1 should have colorbox" do
  colorbox_type = page.evaluate_script("typeof window.jQuery1.colorbox")
  expect(colorbox_type).not_to eq('undefined'), "window.jQuery1 does not have colorbox (type: #{colorbox_type})"
end
