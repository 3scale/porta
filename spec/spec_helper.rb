require 'codeclimate_rails'
CodeclimateRails.start

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

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

require 'api_helper'
require 'database_cleaner'

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.infer_spec_type_from_file_location!

  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = ::Rails.root.join('test', 'fixtures')

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = true

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.around(:each, transactions: false) do |ex|
    require 'database_cleaner'
    transactional = self.use_transactional_fixtures
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
    begin
      ::Backend::Storage.instance.flushdb
    rescue Errno::ECONNREFUSED
      # not running
    end
  end

  config.before(:suite) do
    DatabaseCleaner.clean_with(:deletion)
    master_account
  end

  if ENV['CI']
    FileUtils.mkdir_p(ENV['CI_REPORTS'] ||= "tmp/junit/spec-#{[ENV['MULTIJOB_KIND'], Process.pid].compact.join('-')}")
    require 'ci/reporter/rake/rspec_loader'
    config.add_formatter CI::Reporter::RSpecFormatter
  end
end

RspecApiDocumentation.configure do |config|
  config.docs_dir = Rails.root.join(*%w|doc api|)
  # html pages with the wURL console
  config.format = [:json, :wurl, :combined_text]
  # html pages without the wURL console
  #config.format = [:json, :html]
  #config.url_prefix = "/docs"
  config.curl_host = 'http://localhost:3000'
  config.api_name = "Example App API"
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
