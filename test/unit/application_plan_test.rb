require 'test_helper'

class ApplicationPlanTest < ActiveSupport::TestCase

  should belong_to :partner

  should 'not allow setting of end_user_required' do
    plan = Factory(:application_plan)
    plan.end_user_required = true

    assert plan.invalid?
    assert !plan.errors[:end_user_required].blank?

    plan.issuer.account.settings.allow_end_users!
    plan.reload

    assert plan.valid?
  end



  context '#customize' do
    setup do
      @app_plan = Factory(:application_plan)
      @original_plan_metric = Factory(:plan_metric, :plan => @app_plan,
                                      :visible => false, :limits_only_text => false)
      @original_usage_limit = Factory(:usage_limit, :plan => @app_plan,
                                      :period => "year", :value => 666)
    end

    should 'clone plan_metrics' do
      custom_plan = @app_plan.customize
      custom_plan_metric = custom_plan.plan_metrics.first

      assert custom_plan.plan_metrics.count == @app_plan.plan_metrics.count
      assert custom_plan_metric.visible == @original_plan_metric.visible
      assert custom_plan_metric.limits_only_text == @original_plan_metric.limits_only_text
    end

    should 'clone usage_limits' do
      custom_plan = @app_plan.customize
      custom_usage_limit = custom_plan.usage_limits.first

      assert custom_plan.usage_limits.count == @app_plan.usage_limits.count
      assert custom_usage_limit.period == @original_usage_limit.period
      assert custom_usage_limit.value == @original_usage_limit.value
    end

  end # customize
end
