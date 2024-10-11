# frozen_string_literal: true

require 'selenium/webdriver'

# Capybara.default_max_wait_time = 10
Capybara.disable_animation = true
Capybara.javascript_driver = :headless_chrome
Capybara.match = :prefer_exact # TODO: this is Capybara v1 default, we should use :one or :smart
Capybara.server = :webrick # default is :puma

BASE_DRIVER_OPTIONS = {
  args: [
    # This is added in Capybara's default drivers. See https://github.com/teamcapybara/capybara/blob/0480f90168a40780d1398c75031a255c1819dce8/lib/capybara/registrations/drivers.rb#L37-L38
    # Workaround https://bugs.chromium.org/p/chromedriver/issues/detail?id=2650&q=load&sort=-id&colspec=ID%20Status%20Pri%20Owner%20Summary
    '--disable-site-isolation-trials',
    # When width < 1200px, vertical navigation overlaps the page's main content and that will make
    # some cucumbers fail
    '--window-size=1200,2048',
  ]
}.freeze

Before '@chrome' do
  Capybara.current_driver = :chrome
end

# Use this driver to debug scenarios locally by adding tag @chrome on top of the scenario
Capybara.register_driver :chrome do |app|
  options = Selenium::WebDriver::Options.chrome(**BASE_DRIVER_OPTIONS)

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Options.chrome(**BASE_DRIVER_OPTIONS)

  options.logging_prefs = { performance: 'ALL', browser: 'ALL' }

  options.add_option(:perf_logging_prefs, enableNetwork: true)

  options.add_argument('--headless=new')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-popup-blocking')
  options.add_argument('--host-resolver-rules=MAP * ~NOTFOUND , EXCLUDE *localhost*')
  options.add_argument('--disable-gpu')

  options.add_preference(:browser, set_download_behavior: { behavior: 'allow' })

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options, timeout: 120)
end
