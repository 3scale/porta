require 'test_helper'

class ThreeScale::Analytics::UserTrackingTest < ActiveSupport::TestCase
  include ThreeScale::Analytics

  def setup
    account = FactoryBot.build_stubbed(:simple_provider)
    @user = FactoryBot.build_stubbed(:user, account: account, email: 'foo@example.net', first_name: 'John', last_name: 'Doe')
  end

  def teardown
    clean_segment_adapter
  end

  class SegmentEnabled < UserTrackingTest
    def setup
      super
      System::Application.config.three_scale.segment.stubs(enabled: true)
    end

    test 'track uses segment' do
      UserTracking::Segment.expects(:track).once
      UserTracking.new(@user).track('foo')
    end

    test 'identify uses segment' do
      UserTracking::Segment.expects(:identify).once
      UserTracking.new(@user).identify(trait: 'value')
    end

    test 'flush uses segment' do
      UserTracking::Segment.expects(:flush).once
      UserTracking.new(@user).flush
    end

    test 'group uses segment' do
      UserTracking::Segment.expects(:group).once
      UserTracking.new(@user).group
    end

    test 'experiment tracks and identify' do
      tracking = UserTracking.new(@user)

      UserTracking::Segment.expects(:identify)
          .with(has_entry(traits: has_entry('Experiment: Some Name' => 'variant')))
      UserTracking::Segment.expects(:track)
          .with(has_entry(properties: { variation: 'variant'}))

      tracking.experiment('Some Name', 'variant')
    end

    test 'with options' do
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

    test 'basic traits' do
      traits = UserTracking.new(nil).basic_traits
      assert_equal Hash.new, traits

      traits = UserTracking.new(@user).basic_traits

      assert_equal @user.email, traits[:email]
      assert_equal @user.decorate.full_name, traits[:name]
    end

    test 'identify' do
      tracking = UserTracking.new(nil)
      refute tracking.identify

      tracking = UserTracking.new(@user)
      assert tracking.identify

      @user.account.provider = false
      refute tracking.identify
    end

    test 'track' do
      tracking = UserTracking.new(nil)
      refute tracking.track('Event')

      tracking = UserTracking.new(@user)
      assert tracking.track('Event')

      @user.account.provider = false
      refute tracking.track('Event')
    end

    test 'group' do
      tracking = UserTracking.new(nil)
      refute tracking.group

      tracking = UserTracking.new(@user)
      assert tracking.group

      @user.account.provider = false
      refute tracking.group
    end

    test 'group traits' do
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

    test 'can_send?' do
      refute UserTracking.new(nil).can_send?
      assert UserTracking.new(@user).can_send?
    end

    test 'only track providers' do
      @user.account.provider = false
      refute UserTracking.new(@user).can_send?
    end

    test 'do not track impersonation admins' do
      @user.username = ThreeScale.config.impersonation_admin['username']
      refute UserTracking.new(@user).can_send?
    end
  end

  class SegmentDisabled < UserTrackingTest
    def setup
      super
      System::Application.config.three_scale.segment.stubs(enabled: false)
    end

    test 'does not track' do
      expect_not_contact_segment(:track)

      UserTracking.new(@user).track('foo')
    end

    test 'does not flush' do
      expect_not_contact_segment(:flush)

      UserTracking.new(@user).flush
    end

    test 'does not identify' do
      expect_not_contact_segment(:identify)

      UserTracking.new(@user).identify
    end

    test 'does not group' do
      expect_not_contact_segment(:group)

      UserTracking.new(@user).group
    end

    private

    def expect_not_contact_segment(action_name)
      UserTracking::TrackingAdapter::NullAdapter.any_instance.expects(action_name)
    end
  end

  private

  def clean_segment_adapter
    ThreeScale::Analytics::UserTracking::Segment.instance_variable_set(:@adapter, nil)
  end
end
