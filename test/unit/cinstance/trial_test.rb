require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Cinstance::TrialTest < ActiveSupport::TestCase

  def test_notify_about_expired_trial_periods
    plan = nil

    Timecop.freeze(2010, 1, 1) do
      provider  = FactoryBot.create(:provider_account,
                    payment_gateway_options: { test: false })
      plan      = FactoryBot.create(:application_plan,
                    issuer: provider.default_service,
                    trial_period_days: 20, cost_per_month: 10)

      FactoryBot.create(:cinstance, plan: plan)
    end
    
    Timecop.freeze(2010, 1, 5) do
      Cinstances::CinstanceExpiredTrialEvent.expects(:create).never
      Cinstance.notify_about_expired_trial_periods
    end

    # the plan has a trial period
    Timecop.freeze(2010, 1, 21) do
      Cinstances::CinstanceExpiredTrialEvent.expects(:create).once
      Cinstance.notify_about_expired_trial_periods
    end

    # the plan does not have a trial period
    plan.update_attributes(trial_period_days: 0)
    Timecop.freeze(2010, 1, 21) do
      Cinstances::CinstanceExpiredTrialEvent.expects(:create).never
      Cinstance.notify_about_expired_trial_periods
    end
  end

  context 'with 30 days trial period plan' do
    setup do
      @plan = Factory(:application_plan, :trial_period_days => 30)
    end

    should 'compute correct expiration date' do
      Timecop.freeze(2009,11,4) do
        cinstance = Factory(:cinstance, :plan => @plan)
        expected = (cinstance.created_at  + 30.days).to_date
        assert_equal expected, cinstance.trial_period_expires_at.to_date
      end
    end

    should 'expire the trial after 31 days' do
      Timecop.freeze
      cinstance = Factory(:cinstance, :plan => @plan)
      Timecop.travel(31.days.from_now) { assert !cinstance.trial? }
    end

    context 'with no trial' do
      setup do
        @plan = Factory(:application_plan, :trial_period_days => nil)
      end

      should 'find those expired yesterday' do
        Timecop.travel(3.days.from_now) { @cinstance = Factory(:cinstance, :plan => @plan) }

        Timecop.travel(4.days.from_now) do
          found = Cinstance.with_trial_period_expired(Time.zone.now - 1.day)
          assert_equal 1, found.size
          assert_equal @cinstance.id, found.first.id
        end
      end
    end
  end




  test 'trial? returns false if plan has no trial period' do
    plan = Factory(:application_plan, :trial_period_days => 0)
    cinstance = Factory(:cinstance, :plan => plan)

    assert !cinstance.trial?
  end

  test 'trial? accepts a date as argument' do
    plan = Factory(:application_plan, :trial_period_days => 0)
    cinstance = Factory(:cinstance, :plan => plan)

    expires_at = Time.parse('2017-11-13T08:00:00-09:00') # 17:00:00 UTC
    cinstance.expects(:trial_period_expires_at).at_least_once.returns(expires_at)

    now = Time.parse('2017-11-13T17:00:00+01:00') # 16:00:00 UTC
    assert cinstance.trial?(now)

    now = Time.parse('2017-11-13T19:00:00+01:00') # 18:00:00 UTC
    refute cinstance.trial?(now)
  end

  should 'remaining_trial_period_days returns remaining days of trial period'
  # do
  #     plan = Factory(:plan, :trial_period_days => 30)
  #     cinstance = Cinstance.new(:plan => plan)

  #     assert_equal 30, cinstance.remaining_trial_period_days

  #     Timecop.travel(10.days.from_now) do
  #       assert_equal 20, cinstance.remaining_trial_period_days
  #     end

  #     Timecop.travel(30.days.from_now) do
  #       assert_equal 0, cinstance.remaining_trial_period_days
  #     end
  #   end

  test 'Cinstance#remaining_trial_period_days returns 0 if trial period expired' do
    plan = Factory(:application_plan, :trial_period_days => 30)
    cinstance = Factory(:cinstance, :plan => plan)

    Timecop.travel(40.days.from_now) do
      assert_equal 0, cinstance.remaining_trial_period_days
    end
  end
end
