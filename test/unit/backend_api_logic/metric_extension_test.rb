# frozen_string_literal: true

require 'test_helper'

class MetricExtensionTest < ActiveSupport::TestCase
  setup do
    @backend_api = FactoryBot.create(:backend_api)
    @metric = FactoryBot.build(:metric, system_name: 'whatever', service_id: nil, owner: @backend_api)
  end

  attr_reader :backend_api, :metric

  test 'extends metric system_name with backend api id' do
    assert metric.save
    assert_equal "whatever.#{backend_api.id}", metric.reload.attributes['system_name']
  end

  test 'keeps showing system name without the suffix' do
    assert metric.save
    assert_equal "whatever", metric.system_name
  end

  test '#backend_api_metric?' do
    assert metric.backend_api_metric?
    service_metric = FactoryBot.create(:metric)
    refute service_metric.backend_api_metric?
  end
end
