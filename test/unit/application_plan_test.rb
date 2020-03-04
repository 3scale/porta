require 'test_helper'

class ApplicationPlanTest < ActiveSupport::TestCase

  should belong_to :partner

  test '.provided_by' do
    tenants = FactoryBot.create_list(:simple_provider, 2)
    tenants.each do |tenant|
      service = FactoryBot.create(:simple_service, account: tenant)
      FactoryBot.create_list(:application_plan, 2, issuer: service)
    end

    assert_equal({}, ApplicationPlan.provided_by(''))
    assert_equal({}, ApplicationPlan.provided_by(:all))
    tenants.each do |tenant|
      assert_same_elements ApplicationPlan.where(issuer_id: tenant.services.first).pluck(:id), ApplicationPlan.provided_by(tenant).pluck(:id)
    end
  end

  context '#customize' do
    setup do
      @app_plan = FactoryBot.create(:application_plan)
      @original_plan_metric = FactoryBot.create(:plan_metric, :plan => @app_plan,
                                      :visible => false, :limits_only_text => false)
      @original_usage_limit = FactoryBot.create(:usage_limit, :plan => @app_plan,
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
