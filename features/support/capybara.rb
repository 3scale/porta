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

Capybara.default_driver = :rack_test
Capybara.javascript_driver = DEFAULT_JS_DRIVER
Capybara.default_selector    = :css
Capybara.ignore_hidden_elements = false

# see http://www.elabs.se/blog/60-introducing-capybara-2-1
Capybara.configure do |config|
  config.default_driver = :rack_test
  config.javascript_driver = DEFAULT_JS_DRIVER
  config.raise_server_errors = true
  config.match = :prefer_exact
  config.ignore_hidden_elements = false
  config.always_include_port = true
  config.default_max_wait_time = 10
end

# Needed because cucumber-rails requires capybara/cucumber
# https://github.com/cucumber/cucumber-rails/blob/7b47bf1dda3368247bf2d45bcb17a224e80ec6fd/lib/cucumber/rails/capybara.rb#L3
# https://github.com/teamcapybara/capybara/blob/2.18.0/lib/capybara/cucumber.rb#L17-L19
Before '@javascript' do
  Capybara.current_driver = DEFAULT_JS_DRIVER
end


# monkeypatch to fix
# not opened for reading (IOError)
# /cucumber-1.3.20/lib/cucumber/formatter/interceptor.rb:33:in `each'
# /cucumber-1.3.20/lib/cucumber/formatter/interceptor.rb:33:in `collect'
# /cucumber-1.3.20/lib/cucumber/formatter/interceptor.rb:33:in `method_missing'
# /airbrake-4.3.0/lib/airbrake/utils/params_cleaner.rb:129:in `clean_unserializable_data'
# /airbrake-4.3.0/lib/airbrake/utils/params_cleaner.rb:122:in `block in clean_unserializable_data'
# /airbrake-4.3.0/lib/airbrake/utils/params_cleaner.rb:121:in `each'
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
  options.add_argument('--window-size=1280,1024')

  driver = Capybara::Selenium::Driver.new(app, browser: :firefox, options: options)

  driver
end

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new

  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-popup-blocking')
  options.add_argument('--window-size=1280,1024')

  options.add_preference(:browser, set_download_behavior: { behavior: 'allow' })

  driver = Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)

  driver
end
