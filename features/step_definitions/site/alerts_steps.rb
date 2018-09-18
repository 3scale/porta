Given "I don't care about backend alert limits" do
  Service.any_instance.stubs(:alert_limits).returns([])
  Service.any_instance.stubs(:create_alert_limits).returns([])
  Service.any_instance.stubs(:delete_alert_limits).returns([])
end

Given "I care about backend alert limits" do
  Service.any_instance.unstub(:alert_limits)
  Service.any_instance.unstub(:create_alert_limits)
  Service.any_instance.unstub(:delete_alert_limits)
end

When /^default service of (provider ".+?") has allowed following alerts:$/ do |provider, table|
  service = provider.first_service!
  settings = service.notification_settings || {}

  table.hashes.each do |row|
    key = "#{row['How']}_#{row['Who']}".to_sym
    settings[key] = row['Levels'].from_sentence.map(&:to_i)
  end

  service.update_attribute :notification_settings, settings
end

Then /^I should see alert settings:$/ do |table|
  body = extract_table 'table#notification-settings-table',  'tbody tr', lambda { |tr|
    [tr.text, tr.all(:xpath, '*').map{ |td| td.all(:xpath, '*').map{|input| input['value'] }.join } ].flatten
  }
  table.diff! body
end

Then /^I should see all alerts off$/ do
  assert !all("input[@type='checkbox']").any? { |cb| cb.checked? }
end

Then /^I should see checked alert "(.*?)" in "(.*?)" row$/ do |value, row|
  within :xpath, "//tbody/tr[ th[text() = '#{row}'] ]" do
    assert find(:xpath, "//input[@value = '#{value}']").checked?
  end
end

When /^I (check|uncheck) alert "(.*?)" in "(.*?)" row$/ do |tick, value, row|
  within :xpath, "//tbody/tr[ th[text() = '#{row}'] ]" do
    find(:xpath, "//input[@value = '#{value}']").set(tick == 'check')
  end
end
