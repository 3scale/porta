require 'test_helper'

class ThreeScale::Analytics::UserTrackingTest < ActiveSupport::TestCase
  include ThreeScale::Analytics

  def setup
    account = FactoryBot.build_stubbed(:simple_account, provider: true)
    @user = FactoryBot.build_stubbed(:user, account: account, email: 'foo@example.net')
  end

  def test_track_uses_segment
    UserTracking::Segment.expects(:track).once
    UserTracking.new(@user).track('foo')
  end

  def test_identify_uses_segment
    UserTracking::Segment.expects(:identify).once
    UserTracking.new(@user).identify(trait: 'value')
  end

  def test_flush_uses_segment
    UserTracking::Segment.expects(:flush).with().once
    UserTracking.new(@user).flush
  end

  def test_group_uses_segment
    UserTracking::Segment.expects(:group).once
    UserTracking.new(@user).group
  end

  def test_experiment
    tracking = UserTracking.new(@user)

    UserTracking::Segment.expects(:identify)
        .with(has_entry(traits: has_entry('Experiment: Some Name' => 'variant')))
    UserTracking::Segment.expects(:track)
        .with(has_entry(properties: { variation: 'variant'}))

    tracking.experiment('Some Name', 'variant')
  end

  def test_with_options
    tracking = UserTracking.new(@user)

    timestamp = 1.hour.from_now

    seq = sequence('segment')

    UserTracking::Segment.expects(:identify).in_sequence(seq).with(has_entry(timestamp: timestamp))

    UserTracking::Segment.expects(:identify).in_sequence(seq).with(Not(has_key(:timestamp)))

    tracking.with_segment_options(timestamp: timestamp) do
      tracking.identify
    end

    tracking.identify
  end

  def test_basic_traits
    traits = UserTracking.new(nil).basic_traits
    assert_equal Hash.new, traits

    traits = UserTracking.new(@user).basic_traits

    assert_equal traits.slice(:email), email: @user.email
  end

  def test_identify
    tracking = UserTracking.new(nil)
    refute tracking.identify

    tracking = UserTracking.new(@user)
    assert tracking.identify

    @user.account.provider = false
    refute tracking.identify
  end


  def test_track
    tracking = UserTracking.new(nil)
    refute tracking.track('Event')

    tracking = UserTracking.new(@user)
    assert tracking.track('Event')

    @user.account.provider = false
    refute tracking.track('Event')
  end

  def test_group
    tracking = UserTracking.new(nil)
    refute tracking.group

    tracking = UserTracking.new(@user)
    assert tracking.group

    @user.account.provider = false
    refute tracking.group
  end

  def test_group_traits
    tracking = UserTracking.new(nil)
    assert_equal Hash.new, tracking.group_traits

    tracking = UserTracking.new(@user)
    @user.account.stubs(bought_plan: Plan.new(name: 'fooplan', cost_per_month: 42), state: 'suspended')

    assert_equal({name: @user.account.name,
                  plan: 'fooplan',
                  monthly_spend: 42.0,
                  license_mrr: 42.0,
                  state: 'suspended',
                 }, tracking.group_traits)
  end

  def test_can_send?
    refute UserTracking.new(nil).can_send?
    assert UserTracking.new(@user).can_send?
  end

  def test_only_track_providers
    @user.account.provider = false
    refute UserTracking.new(@user).can_send?
  end

  def test_do_not_track_impersonation_admins
    @user.username = ThreeScale.config.impersonation_admin['username']
    refute UserTracking.new(@user).can_send?
  end
end
