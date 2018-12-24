require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

class Backend::ModelExtensions::UsageLimitTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  def expect_save_for(usage_limit, without: [], with: {}, &blk)
    entries = {
      service_id: usage_limit.service.backend_id.to_s,
      plan_id: usage_limit.plan.id,
      metric_id: usage_limit.metric.id,
      usage_limit.period.to_sym => usage_limit.value
    }

    entries.merge! with

    Array(without).each do |k|
      entries.delete k
    end

    # with(has_entries) has the entries not evaluated if it has a block :/
    ThreeScale::Core::UsageLimit.expects(:save).with do |attrs|
      entries.all? do |k, v|
        attrs[k] == v
      end and (blk ? yield(attrs) : attrs[usage_limit.period.to_sym] == usage_limit.value)
    end
  end

  def test_preload_used_associations
    usage_limit = FactoryBot.create(:usage_limit)

    usage_limit.expects(:service).returns(nil).at_least_once

    assert usage_limit.destroy
  end

  def test_delete_backend_usage_limit
    usage_limit = FactoryBot.create(:usage_limit)

    usage_limit.expects(:service).returns(nil).at_least_once

    ThreeScale::Core::UsageLimit.expects(:delete).never

    assert usage_limit.destroy
  end

  test 'stores usage_limit backend data when usage_limit is created' do
    plan   = Factory(:application_plan)
    metric = Factory(:metric, :service => plan.service)

    usage_limit = metric.usage_limits.new(:period => :week, :value => 7000)
    usage_limit.plan = plan

    expect_save_for usage_limit

    usage_limit.save!
  end

  test 'stores usage_limit backend data when usage_limit is created for end user plan with right backend_id' do
    service = Factory(:service)
    plan   = Factory(:end_user_plan, :service => service)
    metric = Factory(:metric, :service => service)

    usage_limit = metric.usage_limits.new(:period => :week, :value => 7000)
    usage_limit.plan = plan

    expect_save_for usage_limit, with: { service_id: service.backend_id, plan_id: plan.backend_id, metric_id: metric.id}

    usage_limit.save!
  end

  test 'updates usage_limit backend data when usage_limit changes period' do
    usage_limit = Factory(:usage_limit, :period => :month, :value => 2000)

    ThreeScale::Core::UsageLimit.expects(:save).with(has_key(:month)).never

    usage_limit.period = :day

    expect_save_for usage_limit

    usage_limit.save!
  end

  test 'updates usage_limit backend data when usage_limit changes value' do
    usage_limit = Factory(:usage_limit, :period => :month, :value => 2000)

    usage_limit.value = 3000

    expect_save_for usage_limit

    usage_limit.save!
  end

  test 'updates usage_limit backend data when usage_limit changes value with right plan backend_id' do
    service = Factory(:service)
    plan   = Factory(:end_user_plan, :service => service)

    usage_limit = Factory(:usage_limit, :period => :month, :value => 2000, :plan => plan)

    usage_limit.value = 3000

    expect_save_for usage_limit, with: { service_id: service.backend_id, plan_id: plan.backend_id }

    usage_limit.save!
  end


  test 'does not update usage_limit backend data when validation fails' do
    ThreeScale::Core::UsageLimit.expects(:save).with(has_key(:seven_years)).never
    ThreeScale::Core::UsageLimit.expects(:save).with(has_key(:month)).once

    usage_limit = Factory(:usage_limit, :period => :month, :value => 2000)

    usage_limit.period = :seven_years

    usage_limit.save

    assert !usage_limit.valid?
  end

  test 'deletes usage_limit backend data when usage_limit is destroyed' do
    usage_limit = Factory(:usage_limit, :period => :month, :value => 2000)

    ThreeScale::Core::UsageLimit.expects(:delete).with(
      usage_limit.service.backend_id, usage_limit.plan.id, usage_limit.metric.id, usage_limit.period)

    usage_limit.destroy
  end
end
