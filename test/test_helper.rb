# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

junit_reporter_path = 'tmp/junit/unit'

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
  junit_reporter_path = "#{junit_reporter_path}-#{ENV['CIRCLE_NODE_INDEX']}"
end

require File.expand_path(File.dirname(__FILE__) + "/../config/environment")

require 'minitest/unit'

require 'rails/test_help'
require "paperclip/matchers"

require File.expand_path('../lib/developer_portal/test/test_helper.rb', __dir__)

require 'minitest/reporters'

report_dir = [junit_reporter_path, Process.pid].compact.join('-')
# junit = MiniTest::Reporters::JUnitReporter.new(report_dir)

# this environment variable is set by Intellij IDEA which is not compatible with those reporters
unless ENV['RM_INFO']
  require 'minitest/ci'
  Minitest::Ci.report_dir = report_dir
  # we skip this for IntelliJ IDEA compatibility
  # MiniTest::Reporters.use!([junit, MiniTest::Reporters::DefaultReporter.new])
  MiniTest::Reporters.use!([MiniTest::Reporters::DefaultReporter.new])
end

require 'webmock/minitest'
WebMock.enable!

WebMock.disable_net_connect!

class ActiveSupport::TestCase
  self.use_transactional_tests = true
  self.use_instantiated_fixtures  = false

  extend Paperclip::Shoulda::Matchers

  Aws.config[:s3] = { stub_responses: true }

  def assert_not_match(regexp, str)
    assert_not (str =~ Regexp.compile(regexp)), "Should not match '#{regexp}'"
  end

  def assert_can(ability, *args)
    assert ability.can?(*args), "User is not able to #{args.join(' ')}"
  end

  def assert_cannot(ability, *args)
    assert ability.cannot?(*args), "User can #{args.join(' ')} but should not"
  end

  def teardown
    User.current = nil
    Timecop.return
  end
end

# Load test helpers
Dir[File.dirname(__FILE__) + '/test_helpers/**/*.rb'].each { |file| require file }

# Support classes that are not shared with cucumber
Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each { |file| require file }

include TestHelpers::XmlAssertions
include TestHelpers::SectionsPermissions

ActiveJobUniquenessTestHelper.active_job_uniqueness_test_mode!

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :minitest
    with.library :rails
  end
end
