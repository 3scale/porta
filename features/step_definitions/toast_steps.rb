# frozen_string_literal: true

Given /^a(?: )?(\w+)? toast alert is displayed with text "(.*)"$/ do |type, message|
  page.execute_script "window.ThreeScale.toast('#{message}', '#{type || :default}')"
end

Then /^(?:they )?should see a(?: )?(\w+)? toast alert with text "(.*)"$/ do |type, message|
  within '.pf-c-alert-group.pf-m-toast' do
    find(".pf-c-alert#{type ? %(.pf-m-#{type}) : nil} .pf-c-alert__title", text: message)
  end
end

Then "they should not see any toast alerts" do
  within('.pf-c-alert-group.pf-m-toast', visible: :all) do
    assert_no_css '.pf-c-alert', wait: 1
  end
end
