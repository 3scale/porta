# frozen_string_literal: true

When('I {enable} the plan feature {string}') do |enable, feature_name|
  within(:xpath, "//tr[td[text() = '#{feature_name}' and @class='title']]") do
    if enable
      find('i.excluded').click
    else
      find('i.included').click
    end
  end
end

When('I click {string} for the plan feature {string}') do |action, feature_name|
  within(:xpath, "//tr[td[text() = '#{feature_name}' and @class='title']]") do
    element = find(".action", text: action)
    element.click
  end
end

Then('I see the plan feature {string} is {enabled}') do |feature_name, enabled|
  wait_for_requests
  within(:xpath, "//tr[td[text() = '#{feature_name}' and @class='title']]") do
    if enabled
      assert_selector('i.included[title="Feature is enabled for this plan"]', visible: true)
    else
      assert_selector('i.excluded[title="Feature is disabled for this plan"]', visible: true)
    end
  end
end
