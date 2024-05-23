# frozen_string_literal: true

Before '@onpremises' do
  ThreeScale.config.stubs(onpremises: true)
  ThreeScale.config.stubs(saas?: false)
end

After '@onpremises' do
  ThreeScale.config.stubs(onpremises: false)
  ThreeScale.config.stubs(saas?: true)
end

Before '@ignore-backend' do
  stub_backend_get_keys
  stub_backend_change_provider_key
  stub_backend_referrer_filters
  stub_backend_utilization
  BackendClient::ToggleBackend.disable_all!
end

Before '@backend' do
  BackendClient::ToggleBackend.enable_all!
end

After do
  clear_backend_stubs
end

Before '@javascript' do
  stub_core_reset!
  @javascript = true
end

AfterStep('@javascript') do
  if @provider
    @provider.services.pluck(:id).each do |id|
      stub_core_integration_errors(service_id: id)
    end
  end
end

Before do
  begin
    Backend::Storage.instance.flushdb
  rescue Errno::ECONNREFUSED, ::Redis::CannotConnectError, ::Errno::EINVAL
  end
end

AfterStep('@pause') do
  print "Press Return to continue"
  STDIN.getc
end

Before '@ignore-backend-alerts' do
  Service.any_instance.stubs(:alert_limits).returns([])
  Service.any_instance.stubs(:create_alert_limits).returns([])
  Service.any_instance.stubs(:delete_alert_limits).returns([])
end

After '@ignore-backend-alerts' do
  Service.any_instance.unstub(:alert_limits)
  Service.any_instance.unstub(:create_alert_limits)
  Service.any_instance.unstub(:delete_alert_limits)
end

Before '@recaptcha' do
  skip_recaptcha(false)
end

After '@recaptcha' do
  skip_recaptcha(true)
end

AfterStep do
  page.raise_server_error!
end

Before('@saas-only') do
  raise ::Cucumber::Core::Test::Result::Skipped, 'SaaS only features do not support OracleDB' if System::Database.oracle?
end

After do |scenario| # rubocop:disable Metrics/BlockLength
  next unless scenario.failed? # we don't care about working scenarios

  if (console_messages = page.driver.try(:console_messages))
    puts "Console Messages:", *console_messages
  end

  if (error_messages = page.driver.try(:error_messages))
    puts "Error Messages:", *error_messages
  end


  folder = Pathname.new(scenario.location.file)
  if folder.absolute?
    folder = folder.relative_path_from(Rails.root)
  end

  root = Capybara.save_path

  $_cleaned_up ||= Set.new

  root.join(folder).tap do |full_path|
    # clean folder only ONCE per test run
    # or we could clean up the root just once
    # but someone can keep old files there, so rather not

    unless $_cleaned_up.include?(full_path)
      full_path.rmtree if full_path.exist?
    end
    $_cleaned_up << full_path

    full_path.mkpath
  end

  folder = folder.expand_path(root)

  line_number = scenario.location.line.to_s

  # Network logs
  if page.driver.browser.respond_to?(:manage)
    # performance logs may fail if this logging type is not configured or not supported by driver
    if page.driver.browser.manage.logs.available_types.include? :performance
      logs = page.driver.browser.manage.logs.get(:performance)
      array = logs.each_with_object([]) do |entry, messages|
        message = JSON.parse(entry.message)
        # next unless message.dig('message', 'params', 'documentURL').to_s.end_with? '/p/login'
        messages << message
      end

      file = folder.join("#{line_number}-network.json")
      file.open('w') do |f|
        f.puts JSON.dump(array)
      end
    else
      warn "Browser driver not configured to collect performance logs."
    end


    console_log = folder.join("#{line_number}.log")

    if (logs = page.driver.browser.manage.logs.get(:browser)).present?
      entries = logs.map{ |entry| "[#{entry.level}] #{entry.message}" }

      console_log.open('w') do |f|
        f.puts *entries
      end

      print "Saved console log to #{console_log}\n"
    end

  end

  if (ex = scenario.try(:exception)) # `try` so it does not raise on undefined method
    file = folder.join("#{line_number}.txt")
    file.open('w') do  |f|
      if (table = ex.try(:table))
        f.puts table.to_s, ''
      end
      f.puts ex.to_s, "",  *ex.backtrace
    end

    if (cause = ex.cause)
      file = folder.join("#{line_number}-cause.txt")
      file.open('w') do  |f|
        f.puts cause.to_s, "",  *cause.backtrace
      end
    end

    print "Saved exception with backtrace to #{file}\n"
  end

  begin
    next unless current_path # failed before there was page loaded
  rescue URI::InvalidURIError
    # nothing, stats urls have a state in the anchor and ruby URI parsing fails
  rescue Errno::EPIPE # server already died?
    next
  end

  print "Saved page body to #{Capybara.save_page(folder.join("#{line_number}.html"))}\n"

  begin
    print "Saved screenshot to #{Capybara.save_screenshot(folder.join("#{line_number}.png"))}\n"
  rescue Capybara::NotSupportedByDriverError
    # and that is fine! rack-test does not support screenshots
  end
end

After do |scenario|
  if ENV['FAIL_FAST']
    Cucumber.wants_to_quit = true if scenario.failed?
  end
end

# TODO: create hooks for Braintree and Stripe for tests requiring JS. Use a proxy to mock requests made
# from browser (Stripe.js). We could use https://github.com/oesmith/puffing-billy or similar
#
# Before '@braintree' do
# Before '@stripe' do

Before '@webhook' do
  stub_request(:any, %r{3scale-test.org}).to_return(status: 200, body: '')
end

current_step = ->(scenario) do
  # WARNING: its print is totally invalid for the scenario outlines
  # but you know, it works, and there are not so many in the app
  # when someone needs that, lets fix it
  scenario = scenario.try(:scenario_outline) || scenario
  steps = scenario.test_steps.each.to_a
  index = steps.find_index{ |step| step.status == :skipped }

  [ steps[index], steps[index+1] ]
end

print_banner = ->(title, step) do
  step_name = (step.try(:actual_keyword) || step.keyword) + step.name
  Rails.logger.info <<~NEXT

    | #{title}: #{step_name.bold} |
    | #{'=' * (step_name.length + title.length + 2)} |
    #{step.multiline_arg}
  NEXT
end

Before do |scenario|
  # current, = current_step.(scenario)
  # print_banner.('Starting', current)
end

AfterStep do |scenario|
  # current, next_step = current_step.(scenario)
  # print_banner.('Finished', current)
  # print_banner.('Starting', next_step) if next_step
end

Before '@email-configurations' do
  Features::EmailConfigurationConfig.stubs(enabled?: true)
end
