require 'color'

Before '@fakeweb' do
  WebMock.disable!
end

After '@fakeweb' do
  WebMock.enable!
end

Before '@fakeweb', '@selenium,@javascript' do
  raise '@fakeweb and @selenium or @javascript is not allowed combination of tags. FakeWeb breaks things.'
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
  step "I don't care about backend alert limits"
end

After '@ignore-backend-alerts' do
  step "I care about backend alert limits"
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

Before '@selenium', '~@javascript' do
  abort 'Running with @selenium tag without @javascript is not supported'
  exit!
end

Before '~@javascript' do
  Timecop.scale(100)
end

# run before javascript tests not tagged with selenium
AfterStep '@javascript', '@alert', '~@selenium' do
  stub_javascript_alert
end

AfterStep '@javascript', '@ajax' do
  wait_for_requests
end

Before '@javascript' do
  @javascript = true
end

After do |scenario|
  next unless scenario.failed? # we don't care about working scenarios
  next unless scenario.respond_to?(:feature) # example rows dont have feature


  if (console_messages = page.driver.try(:console_messages))
    puts "Console Messages:", *console_messages
  end

  if (error_messages = page.driver.try(:error_messages))
    puts "Error Messages:", *error_messages
  end


  folder = Pathname.new(scenario.feature.file)
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
  next
  line_number = scenario.line.to_s

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

  console_log = folder.join("#{line_number}.log")

  # # selenium 3 broke logs
  # if (logs = page.driver.browser.try(:manage).try(:logs))
  #     binding.pry
  #   if (entries = logs.get(:browser).presence)
  #     console_log.open('w') do |f|
  #       f.puts *entries
  #     end
  #
  #     print "Saved console log to #{console_log}\n"
  #   end
  # end


  if (logs = page.driver.browser.try(:console_messages)).present?
    entries = logs.map{ |entry| "#{entry[:message]} (#{entry[:source]}:#{entry[:line_number]}" }

    puts *entries
    console_log.open('w') do |f|
      f.puts *entries
    end

    print "Saved console log to #{console_log}\n"
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
    print "Saved sceeenshot to #{Capybara.save_screenshot(folder.join("#{line_number}.png"))}\n"
  rescue Capybara::NotSupportedByDriverError
    # and that is fine! rack-test does not support screenshots
  end
end

After do |scenario|
  if ENV['FAIL_FAST']
    Cucumber.wants_to_quit = true if scenario.failed?
  end
end

Before '@braintree' do
  stub_request(:delete, %r{@sandbox.braintreegateway.com/merchants/.+/customers/valid_code})
      .to_return(status: 200, body: '', headers: {})
end

Before '@webhook' do
  stub_request(:any, %r{google.com}).to_return(status: 200, body: '')
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

print_banner = -> (title, step) do
  step_name = (step.try(:actual_keyword) || step.keyword) + step.name
  Rails.logger.info <<-NEXT

| #{title}: #{Color::BOLD}#{step_name}#{Color::CLEAR} |
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
