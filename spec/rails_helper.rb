# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require 'rspec-html-matchers'

# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

if ENV['CI']
  require 'simplecov'
  require "simplecov_json_formatter"
  require 'codecov'
  formatters = [
    SimpleCov::Formatter::SimpleFormatter,
    SimpleCov::Formatter::JSONFormatter,
    SimpleCov::Formatter::HTMLFormatter,
    Codecov::SimpleCov::Formatter
  ]
  SimpleCov.start do
    formatter SimpleCov::Formatter::MultiFormatter.new(formatters)
  end
end

# Require backend API stubbing
require_relative '../test/test_helpers/backend'
RSpec::Core::ExampleGroup.class_eval do
  include TestHelpers::Backend
end

# Require master test helper
require_relative '../test/test_helpers/master'
RSpec::Core::ExampleGroup.class_eval do
  include TestHelpers::Master
end

# Require FactoryBot configuration
require_relative '../test/test_helpers/factory_bot'

require 'api_helper'
require 'database_cleaner'


RSpec.configure do |config|
  config.include RSpecHtmlMatchers
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/test/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!
  config.raise_errors_for_deprecations!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.around(:each, transactions: false) do |ex|
    require 'database_cleaner'
    transactional = use_transactional_fixtures
    self.use_transactional_fixtures = false

    begin
      DatabaseCleaner.strategy = :transaction
      ex.run
      DatabaseCleaner.clean_with(:deletion)
    ensure
      self.use_transactional_fixtures = transactional
    end
  end

  config.after(:each) do

    User.current = nil
    ::Backend::Storage.instance.flushdb
  rescue Errno::ECONNREFUSED
    # not running

  end

  config.before(:suite) do
    DatabaseCleaner.clean_with(:deletion)
    master_account
  end

  if ENV['CI']
    junit = "tmp/junit/spec-#{[ENV['CIRCLE_NODE_INDEX'], Process.pid].compact.join('-')}/spec.xml"
    config.add_formatter RspecJunitFormatter, junit
  end
end


RspecApiDocumentation.configure do |config|
  config.docs_dir = Rails.root.join('doc', 'api')
  # html pages with the wURL console
  config.format = %i[json wurl combined_text]
  # html pages without the wURL console
  #config.format = [:json, :html]
  #config.url_prefix = "/docs"
  config.curl_host = 'http://localhost:3000'
  config.api_name = "Example App API"
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
