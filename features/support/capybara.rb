# frozen_string_literal: true

require 'selenium/webdriver'

Capybara.configure do |config|
  config.match = :prefer_exact
  config.javascript_driver = :headless_chrome
  config.always_include_port = true
  config.default_max_wait_time = 10
  config.server = :webrick # default is `:default` (which uses puma)
end

# --window-size=1200,2048: When width < 1200px, vertical navigation overlaps the page's main content,
# and that will make some cucumbers fail
BASE_DRIVER_OPTIONS = {
  args: %w[--window-size=1200,2048 --disable-search-engine-choice-screen]
}.freeze

Capybara.register_driver :chrome do |app|
  options = Selenium::WebDriver::Options.chrome(**BASE_DRIVER_OPTIONS)
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Options.chrome(**BASE_DRIVER_OPTIONS)

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
