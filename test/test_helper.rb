# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

require File.expand_path(File.dirname(__FILE__) + "/../config/environment")

require 'codeclimate_rails'
CodeclimateRails.start


require 'minitest/unit'

require 'rails/test_help'
require "paperclip/matchers"
require 'shoulda'

require File.expand_path('../../lib/developer_portal/test/test_helper.rb', __FILE__)

require 'minitest/reporters'

# if not running on jenkins
if ENV['CI']
  junit = MiniTest::Reporters::JUnitReporter.new("tmp/junit/unit-#{[ENV['MULTIJOB_KIND'], Process.pid].compact.join('-')}")
  MiniTest::Reporters.use!([junit, MiniTest::Reporters::DefaultReporter.new])
else
  MiniTest::Reporters.use!([Minitest::Reporters::SpecReporter.new])
end

require 'fakeweb'

require 'webmock/minitest'
WebMock.enable!

WebMock.disable_net_connect!


class ActiveSupport::TestCase
  self.use_transactional_fixtures = true
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
    Timecop.return
  end
end

# Load test helpers
Dir[File.dirname(__FILE__) + '/test_helpers/**/*.rb'].each { |file| require file }

# Support classes that are not shared with cucumber
Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each { |file| require file }

include TestHelpers::XmlAssertions
include TestHelpers::SectionsPermissions
