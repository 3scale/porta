# frozen_string_literal: true

# Silence our custom deprecator in test, production and preview
# Stop to spam
ThreeScale::Deprecation.silenced = %w[test production preview].include?(Rails.env)

# Send deprecation warnings to Bugsnag
ActiveSupport::Notifications.subscribe 'deprecation.rails' do |*args|
  System::ErrorReporting.report_deprecation_warning(args.extract_options!)
end

