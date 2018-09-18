require 'test_helper'

class ThreeScale::Analytics::SessionTest < ActiveSupport::TestCase

  attr_reader :session

  include ThreeScale::Analytics::SessionStoredAnalytics::Helper

  def setup
    @session = {}
  end

  def test_delayed_session
    analytics_session.delayed.one('one')
    analytics_session.delayed.two(two: 2)

    one = analytics_session.shift
    two = analytics_session.shift

    assert_equal [:one, 'one'], one
    assert_equal [:two, {two: 2}], two
  end


end
