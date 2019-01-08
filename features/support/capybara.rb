require 'selenium/webdriver'
require 'capybara/minitest'
include Capybara::Minitest::Assertions

# in case chrome is needed!
#Capybara.register_driver :selenium do |app|
#  Capybara::Selenium::Driver.new(app, :browser => :chrome)
#end

DEFAULT_JS_DRIVER = :headless_chrome
DEFAULT_SELENIUM_DRIVER = :headless_chrome
#DEFAULT_JS_DRIVER = :webkit_debug

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
#
# Before '@selenium' do
#   Capybara.javascript_driver   = :headless_chrome
# end
#
# After '@selenium' do
#   Capybara.javascript_driver   = DEFAULT_JS_DRIVER
# end

# Needed because cucumber-rails requires capybara/cucumber
# https://github.com/cucumber/cucumber-rails/blob/7b47bf1dda3368247bf2d45bcb17a224e80ec6fd/lib/cucumber/rails/capybara.rb#L3
# https://github.com/teamcapybara/capybara/blob/2.18.0/lib/capybara/cucumber.rb#L17-L19
Before '@javascript' do
  Capybara.current_driver = DEFAULT_JS_DRIVER
end
# Before '@javascript' do
#  require 'headless' # this requires Xvfb
#
#  headless = Headless.new :destroy_at_exit => false # otherwise it'll cause issues when running in parallel
#  headless.start
# end

# Capybara::Webkit.configure do |config|
#   config.allow_url('foo.example.com')
#   config.allow_url('admin.foo.example.com')
#   config.allow_url('foo-admin.example.com')
#   config.allow_url('foo-admin.3scale.net')
#   config.allow_url('www.example.com')
#   config.allow_url('master-account.example.com')
#   config.allow_url('foo.3scale.net')
#
#   config.block_unknown_urls
#   config.raise_javascript_errors = true # we would like this to be true, but need to fix our failing tests
# end

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
