# frozen_string_literal: true

When "default service of {provider} has allowed following alerts:" do |provider, table|
  service = provider.first_service!
  settings = service.notification_settings || {}

  table.hashes.each do |row|
    key = "#{row['How']}_#{row['Who']}".to_sym
    settings[key] = row['Levels'].from_sentence.map(&:to_i)
  end

  service.update_attribute :notification_settings, settings
end
