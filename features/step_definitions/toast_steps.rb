# frozen_string_literal: true

Given "a( ){alert_type} toast alert is displayed with text {string}" do |type, message|
  page.execute_script "window.ThreeScale.showToast('#{message}', '#{type}')"
end

Then "they should see a( ){alert_type} toast alert with text {string}" do |type, message|
  within '.pf-c-alert-group.pf-m-toast' do
    find(".pf-c-alert.pf-m-#{type} .pf-c-alert__title", text: message)
  end
end

Then "they should not see any toast alerts" do
  within('.pf-c-alert-group.pf-m-toast', visible: :all) do
    assert_no_css '.pf-c-alert', wait: 1
  end
end

# DEPRECATED

Then "(I )(they )should see the flash message {string}" do |message|
  ActiveSupport::Deprecation.warn '[Cucumber] Deprecated! Use toast.'
  assert_flash(message)
end
