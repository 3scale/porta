require 'test_helper'

class TopTrafficQueryTest < ActiveSupport::TestCase

  def setup
    @provider          = FactoryBot.create :provider_account
    @stats             = Stats::Service.new @provider.first_service!
    @top_traffic_query = TopTrafficQuery.new @stats

    Rails.stubs(:cache).returns(ActiveSupport::Cache::MemCacheStore.new)
  end

  def test_by_range
    cinstances = Array.new(3) do |i|
      create_cinstance.tap do |cinstance|
        fake_traffic! cinstance, range, value: i + 1
      end
    end

    top_apps = @top_traffic_query.by_range range: range

    # response should be an enumerator of TopApplicationData objects
    assert_instance_of Enumerator, top_apps
    assert_instance_of TopTrafficQuery::TopApplicationData, top_apps.first

    # tests for specific position values
    top_app = find_object_in_array top_apps, cinstances[0].id

    assert_equal [3, 3, 3], top_app.positions

    top_app = find_object_in_array top_apps, cinstances[1].id

    assert_equal [2, 2, 2], top_app.positions

    top_app = find_object_in_array top_apps, cinstances[2].id

    assert_equal [1, 1, 1], top_app.positions
  end

  def test_by_range_with_not_allowed_cache
    @top_traffic_query.expects(:cache).never
    @top_traffic_query.expects(:stats_data_for).once.returns({})

    # not allowed is by default
    @top_traffic_query.by_range range: range
  end

  def test_by_range_with_allowed_cache
    @top_traffic_query.expects(:cache).once.yields.returns({})
    @top_traffic_query.expects(:stats_data_for).once

    @top_traffic_query.by_range range: range, cache_allowed: true
  end

  private

  def range
    @range ||= Date.parse('2014-1-1')..Date.parse('2014-1-3')
  end

  def find_object_in_array(array, id)
    array.find { |a| a.id == id }
  end

  # @return [Cinstance]
  def create_cinstance(attributes = {})
    plan = FactoryBot.create(:simple_application_plan, issuer: @provider.first_service!)

    FactoryBot.create(:simple_cinstance, attributes.merge(plan: plan))
  end
end
