# frozen_string_literal: true

require 'selenium/webdriver'
require 'capybara/minitest'
include Capybara::Minitest::Assertions

# in case firefox is needed!
#Capybara.register_driver :selenium do |app|
#  Capybara::Selenium::Driver.new(app, :browser => :firefox)
#end

DEFAULT_JS_DRIVER = :headless_chrome
# in case firefox is needed!
# DEFAULT_JS_DRIVER = :headless_firefox

Capybara.configure do |config|
  config.default_driver = :rack_test
  config.javascript_driver = DEFAULT_JS_DRIVER
  config.default_selector = :css
  config.raise_server_errors = true
  config.match = :prefer_exact
  config.always_include_port = true
  config.default_max_wait_time = 10
  # Capybara 3 changes the default server to Puma. It can be reverted to the previous default of WEBRick by specifying:
  config.server = :webrick
  config.disable_animation = true
end

Around '@security' do |scenario, block|
  with_forgery_protection(&block)
end

# monkeypatch to fix
# not opened for reading (IOError)
# /cucumber-1.3.20/lib/cucumber/formatter/interceptor.rb:33:in `each'
# /cucumber-1.3.20/lib/cucumber/formatter/interceptor.rb:33:in `collect'
# /cucumber-1.3.20/lib/cucumber/formatter/interceptor.rb:33:in `method_missing'
require 'cucumber/formatter/interceptor'
class Cucumber::Formatter::Interceptor::Pipe
  def is_a?(klass)
    super || klass == IO
  end
end

Capybara.register_driver :firefox do |app|
  Capybara::Selenium::Driver.new(app, browser: :firefox)
end

Capybara.register_driver :headless_firefox do |app|
  options = Selenium::WebDriver::Firefox::Options.new

  options.add_argument('-headless')
  options.add_argument('--window-size=1280,2048')

  driver = Capybara::Selenium::Driver.new(app, browser: :firefox, options: options)

  driver
end

Capybara.register_driver :firefox do |app|
  options = Selenium::WebDriver::Firefox::Options.new

  options.add_argument('--window-size=1280,2048')

  driver = Capybara::Selenium::Driver.new(app, browser: :firefox, options: options)

  driver
end

Capybara.register_driver :chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--window-size=1280,2048')
  options.add_argument('--disable-search-engine-choice-screen')
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Options.chrome(
    logging_prefs: { performance: 'ALL', browser: 'ALL' },
    perf_logging_prefs: { enableNetwork: true }
  )

  options.add_argument('--headless=new')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-popup-blocking')
  options.add_argument('--window-size=1280,2048')
  options.add_argument('--host-resolver-rules=MAP * ~NOTFOUND , EXCLUDE *localhost*')
  options.add_argument('--disable-search-engine-choice-screen')
  options.add_argument('--disable-gpu')

  options.add_preference(:browser, set_download_behavior: { behavior: 'allow' })

  timeout = 120 # default 60
  client = Selenium::WebDriver::Remote::Http::Default.new(open_timeout: timeout, read_timeout: timeout)

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options, http_client: client)
end
