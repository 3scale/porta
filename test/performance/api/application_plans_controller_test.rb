require 'performance_helper'

class Api::ApplicationPlansControllerTest < ActionDispatch::PerformanceTest
  self.profile_options = { metrics: [ :wall_time ] }

  def setup
    @plan = Factory(:application_plan)
    @service = @plan.service
    @provider = @service.account

    metrics = @plan.metrics
    hits = metrics.hits

    # metrics
    10.times do |i|
      metrics << Factory(:metric, service: @service)
    end

    # methods
    10.times do
      metrics << Factory(:metric, service: @service, unit: nil, parent: hits)
    end

    # metrics = metrics.to_a

    20.times do
      metrics.sample.usage_limits.create value: rand(10..1000),
                                         period: %w{month day hour minute}.sample,
                                         plan: @plan
    end

    20.times do |i|
      metrics.sample.pricing_rules.create plan: @plan,
                                          cost_per_unit: rand,
                                          min: i+1,
                                          max: i+3
    end

    20.times do |i|
      metrics.sample.plan_metrics.create plan: @plan,
                                         visible: rand(0..1) == 1,
                                         limits_only_text: rand(0..1) == 1
    end

    login! @provider
  end

  def test_edit_page
    get edit_admin_application_plan_path(@plan)
    assert_response :success
  end
end
