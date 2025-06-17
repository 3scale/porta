# frozen_string_literal: true

# Send deprecation warnings to Bugsnag
ActiveSupport::Notifications.subscribe 'deprecation.rails' do |*args|
  System::ErrorReporting.report_deprecation_warning(args.extract_options!)
end

