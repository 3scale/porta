# frozen_string_literal: true

require 'selenium/webdriver'

# When width < 1200px, vertical navigation overlaps the page's main content,
# and that will make some cucumbers fail
WINDOW_SIZE_ARG = '--window-size=1280,2048'

Capybara.configure do |config|
  config.default_driver = :rack_test
  config.match = :prefer_exact
  config.javascript_driver = :headless_chrome
  config.always_include_port = true
  config.default_max_wait_time = ENV.fetch('CAPYBARA_MAX_WAIT_TIME', 10).to_i
  config.server = :webrick # default is `:default` (which uses puma)
  config.default_set_options = { clear: :backspace }
end

Capybara.register_driver :chrome do |app|
  options = Selenium::WebDriver::Options.chrome
  options.add_argument(WINDOW_SIZE_ARG)
  options.add_argument('--disable-search-engine-choice-screen')
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Options.chrome
  options.add_argument(WINDOW_SIZE_ARG)
  options.add_argument('--disable-search-engine-choice-screen')
  options.add_argument('--headless=new')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-popup-blocking')
  options.add_argument('--host-resolver-rules=MAP * ~NOTFOUND , EXCLUDE *localhost*')
  options.add_argument('--disable-gpu')

  options.logging_prefs = { performance: 'ALL', browser: 'ALL' }
  options.add_option(:perf_logging_prefs, enableNetwork: true)

  options.add_preference(:browser, set_download_behavior: { behavior: 'allow' })

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options, timeout: 120)
end

# NOTE: depending on the scenario you will need to add both
# @firefox/@headless_firefox AND @javascript tags
Before '@firefox', '@headless_firefox' do
  Capybara.javascript_driver = :headless_firefox
end

Capybara.register_driver :firefox do |app|
  options = Selenium::WebDriver::Options.firefox
  options.add_argument(WINDOW_SIZE_ARG)
  Capybara::Selenium::Driver.new(app, browser: :firefox, options: options)
end

Capybara.register_driver :headless_firefox do |app|
  options = Selenium::WebDriver::Options.firefox
  options.add_argument(WINDOW_SIZE_ARG)
  options.add_argument('-headless')
  Capybara::Selenium::Driver.new(app, browser: :firefox, options: options)
end
