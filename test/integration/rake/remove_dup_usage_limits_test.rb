require 'test_helper'

class RemoveDupUsageLimitsTest < ActiveSupport::TestCase

  def setup
    @provider = Factory :provider_account
    @service_plan = Factory :service_plan, :issuer => @provider.first_service!
    @application_plan = Factory :application_plan, :issuer => @provider.first_service!, :service => @provider.first_service!
    @metric = Factory :metric, :service => @application_plan.service
  end

  test 'does not remove if there is only one usagelimit' do
    usage_limit = @metric.usage_limits.create(period: :week, value: 1, plan: @application_plan)
    assert_equal 1, @metric.usage_limits.count
    ThreeScale::Rake::RemoveDupUsageLimits.run!
    assert_equal 1, @metric.usage_limits.count
  end

  test 'do not remove if there are two usagelimits for different plans' do
    usage_limit = @metric.usage_limits.create(period: :week, value: 1, plan: @application_plan)
    usage_limit2 = @metric.usage_limits.create(period: :week, value: 1, plan: @service_plan)

    assert_equal 2, @metric.usage_limits.count
    ThreeScale::Rake::RemoveDupUsageLimits.run!
    assert_equal 2, @metric.usage_limits.count
  end

end
