# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

junit_reporter_path = 'tmp/junit/unit'

if ENV['CI']
  require 'simplecov'
  SimpleCov.start

  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov

  junit_reporter_path = "#{junit_reporter_path}-#{ENV['CIRCLE_NODE_INDEX']}"
end

require File.expand_path(File.dirname(__FILE__) + "/../config/environment")

require 'minitest/unit'

require 'rails/test_help'
require "paperclip/matchers"
require 'shoulda'

require File.expand_path('../../lib/developer_portal/test/test_helper.rb', __FILE__)

require 'minitest/reporters'

junit = MiniTest::Reporters::JUnitReporter.new([junit_reporter_path, Process.pid].compact.join('-'))
MiniTest::Reporters.use!([junit, MiniTest::Reporters::DefaultReporter.new])

require 'webmock/minitest'
WebMock.enable!

WebMock.disable_net_connect!

require 'monkey_patches/active_job_test_helper'
class ActiveSupport::TestCase
  self.use_transactional_tests = true
  self.use_instantiated_fixtures  = false

  extend Paperclip::Shoulda::Matchers

  Aws.config[:s3] = { stub_responses: true }

  def assert_not_match(regexp, str)
    assert !(str =~ Regexp.compile(regexp)), "Should not match '#{regexp}'"
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
