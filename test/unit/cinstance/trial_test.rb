# frozen_string_literal: true

require 'test_helper'

class Cinstance::TrialTest < ActiveSupport::TestCase
  test 'notify about expired trial periods' do
    plan = nil

    travel_to(2010, 1, 1) do
      provider = FactoryBot.create(:provider_account, payment_gateway_options: { test: false })
      plan = FactoryBot.create(:application_plan, issuer: provider.default_service, trial_period_days: 20, cost_per_month: 10)

      FactoryBot.create(:cinstance, plan: plan)
    end

    travel_to(2010, 1, 5) do
      Cinstances::CinstanceExpiredTrialEvent.expects(:create).never
      Cinstance.notify_about_expired_trial_periods
    end

    # the plan has a trial period
    travel_to(2010, 1, 21) do
      Cinstances::CinstanceExpiredTrialEvent.expects(:create).once
      Cinstance.notify_about_expired_trial_periods
    end

    # the plan does not have a trial period
    plan.update(trial_period_days: 0)
    travel_to(2010, 1, 21) do
      Cinstances::CinstanceExpiredTrialEvent.expects(:create).never
      Cinstance.notify_about_expired_trial_periods
    end
  end

  class TrialPeriodPlanTest < ActiveSupport::TestCase
    setup do
      @plan = FactoryBot.create(:application_plan, trial_period_days: 30)
    end

    test 'should compute correct expiration date' do
      travel_to(2009,11,4) do
        cinstance = FactoryBot.create(:cinstance, plan: @plan)
        expected = (cinstance.created_at + 30.days).to_date
        assert_equal expected, cinstance.trial_period_expires_at.to_date
      end
    end

    test 'should expire the trial after 31 days' do
      freeze_time
      cinstance = FactoryBot.create(:cinstance, plan: @plan)
      travel_to(31.days.from_now) { assert_not cinstance.trial? }
    end
  end

  class NoTrialPeriodPlanTest < ActiveSupport::TestCase
    setup do
      @plan = FactoryBot.create(:application_plan, trial_period_days: nil)
    end

    test 'should find those expired yesterday' do
      travel_to(3.days.from_now) { @cinstance = FactoryBot.create(:cinstance, plan: @plan) }

      travel_to(4.days.from_now) do
        found = Cinstance.with_trial_period_expired(Time.zone.now - 1.day)
        assert_equal 1, found.size
        assert_equal @cinstance.id, found.first.id
      end
    end
  end

  test 'trial? returns false if plan has no trial period' do
    plan = FactoryBot.create(:application_plan, trial_period_days: 0)
    cinstance = FactoryBot.create(:cinstance, plan: plan)

    assert_not cinstance.trial?
  end

  test 'trial? accepts a date as argument' do
    plan = FactoryBot.create(:application_plan, trial_period_days: 0)
    cinstance = FactoryBot.create(:cinstance, plan: plan)

    expires_at = Time.zone.parse('2017-11-13T08:00:00-09:00') # 17:00:00 UTC
    cinstance.expects(:trial_period_expires_at).at_least_once.returns(expires_at)

    now = Time.zone.parse('2017-11-13T17:00:00+01:00') # 16:00:00 UTC
    assert cinstance.trial?(now)

    now = Time.zone.parse('2017-11-13T19:00:00+01:00') # 18:00:00 UTC
    assert_not cinstance.trial?(now)
  end

  pending_test 'remaining_trial_period_days returns remaining days of trial period'
  #     plan = FactoryBot.create(:plan, trial_period_days: 30)
  #     cinstance = Cinstance.new(plan: plan)

  #     assert_equal 30, cinstance.remaining_trial_period_days

  #     travel_to(10.days.from_now) do
  #       assert_equal 20, cinstance.remaining_trial_period_days
  #     end

  #     travel_to(30.days.from_now) do
  #       assert_equal 0, cinstance.remaining_trial_period_days
  #     end
  #   end

  test 'Cinstance#remaining_trial_period_days returns 0 if trial period expired' do
    plan = FactoryBot.create(:application_plan, trial_period_days: 30)
    cinstance = FactoryBot.create(:cinstance, plan: plan)

    travel_to(40.days.from_now) do
      assert_equal 0, cinstance.remaining_trial_period_days
    end
  end
end
