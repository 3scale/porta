# frozen_string_literal: true

require 'test_helper'

class ApplicationPlanTest < ActiveSupport::TestCase
  def setup
    @app_plan = FactoryBot.create(:application_plan)
    @original_plan_metric = FactoryBot.create(:plan_metric, plan: @app_plan, visible: false, limits_only_text: false)
    @original_usage_limit = FactoryBot.create(:usage_limit, plan: @app_plan, period: "year", value: 666)
  end

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

  test '#customize clone plan_metrics' do
    custom_plan = @app_plan.customize
    custom_plan_metric = custom_plan.plan_metrics.first

    assert_equal app_plan.plan_metrics.count, custom_plan.plan_metrics.count
    assert_equal @original_plan_metric.visible, custom_plan_metric.visible
    assert_equal @original_plan_metric.limits_only_text, custom_plan_metric.limits_only_text
  end

  test '#customize clone usage_limits' do
    custom_plan = @app_plan.customize
    custom_usage_limit = custom_plan.usage_limits.first

    assert_equal @app_plan.usage_limits.count, custom_plan.usage_limits.count
    assert_equal @original_usage_limit.period, custom_usage_limit.period
    assert_equal @original_usage_limit.value, custom_usage_limit.value
  end
end
