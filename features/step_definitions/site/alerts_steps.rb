# frozen_string_literal: true

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

When "default service of {provider} has allowed following alerts:" do |provider, table|
  service = provider.first_service!
  settings = service.notification_settings || {}

  table.hashes.each do |row|
    key = "#{row['How']}_#{row['Who']}".to_sym
    settings[key] = row['Levels'].from_sentence.map(&:to_i)
  end

  service.update!(notification_settings: settings)
end
