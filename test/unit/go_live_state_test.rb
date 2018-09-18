require 'test_helper'

class GoLiveStateTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  should belong_to :account

  def setup
    @go_live_state = GoLiveState.new
  end

  test 'andvance step' do
    @go_live_state.advance(:look_ma_without_hands)
    assert_equal true, @go_live_state.steps.look_ma_without_hands
    assert_equal 'look_ma_without_hands', @go_live_state.recent
  end

  test 'can advance to the next step' do
    @go_live_state.advance(:look_ma_without_hands)
    assert_equal true, @go_live_state.can_advance_to?(:look_ma_without_legs)
  end

  test 'cannot advance to the same step' do
    @go_live_state.advance(:look_ma_without_hands)
    assert_equal false, @go_live_state.can_advance_to?(:look_ma_without_hands)
  end

  test 'cannot advance when finished' do
    @go_live_state.close!
    assert_equal false, @go_live_state.can_advance_to?(:look_ma_without_hands)
  end

  test 'start polling after specific taks has been completed' do
    @go_live_state.advance(:verify_api_sandbox_traffic)
    assert_equal true, @go_live_state.poll?
  end

  test 'do not start polling when user is away' do
    @go_live_state.advance(:away)
    assert_equal false, @go_live_state.poll?
  end

  test 'close' do
    @go_live_state.close!
    assert_equal true, @go_live_state.closed
  end

  test 'open' do
    @go_live_state.close!
    @go_live_state.open!
    assert_equal false, @go_live_state.closed
  end
end
