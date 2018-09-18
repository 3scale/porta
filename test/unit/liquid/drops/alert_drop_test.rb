require 'test_helper'

class Liquid::Drops::AlertTest < ActiveSupport::TestCase
  include AlertsHelper
  include Liquid

  def setup
    @alert = FactoryGirl.build_stubbed(:limit_alert)
    @drop = Drops::Alert.new(@alert)
  end

  test 'returns level' do
    assert_equal @alert.level, @drop.level
  end

  test 'returns friendly message' do
    assert_equal @alert.message, @drop.message
  end

  test 'returns utilization' do
    assert_equal @alert.utilization, @drop.utilization
  end

  test 'returns timestamp' do
    assert_equal @alert.timestamp, @drop.timestamp
  end

  test 'returns description' do
    assert_equal @alert.message, @drop.message
  end

  test 'returns unread?' do
    assert_equal @alert.unread?, @drop.unread?
  end

  test 'returns state' do
    assert_equal @alert.state, @drop.state
  end

  test 'returns formatted_level' do
    assert_equal format_utilization(@alert.level), @drop.formatted_level
  end

  test 'returns dom_level' do
    assert_equal "above-#{utilization_range(@alert.level)}", @drop.dom_level
  end

  test 'returns read_alert_url' do
    assert_match %r{/admin/applications/[0-9]+/alerts/[0-9]+/read},  @drop.read_alert_url
  end

  test 'returns delete_alert_url' do
    assert_match %r{/admin/applications/[0-9]+/alerts/[0-9]+}, @drop.delete_alert_url
  end
end
