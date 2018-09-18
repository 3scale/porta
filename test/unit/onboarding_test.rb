require 'test_helper'

class OnboardingTest < ActiveSupport::TestCase

  def setup
    @onboarding = Onboarding.new
    @onboarding.account_id = 42
    @onboarding.save!
  end

  test 'should initialize with correct initial states' do
    assert_equal 'initial', @onboarding.wizard_state
    assert_equal 'api_pending', @onboarding.bubble_api_state
    assert_equal 'metric_pending', @onboarding.bubble_metric_state
    assert_equal 'mapping_pending', @onboarding.bubble_mapping_state
    assert_equal 'limit_pending', @onboarding.bubble_limit_state
    assert_equal 'deployment_pending', @onboarding.bubble_deployment_state
  end

  test 'wizard should transition to started state when start' do
    assert @onboarding.wizard_start

    assert_equal 'started', @onboarding.wizard_state

    refute @onboarding.wizard_start, 'cant start wizard twice'
  end

  test 'wizard should transition to completed state when finish' do
    @onboarding.finish_wizard

    assert_equal 'completed', @onboarding.wizard_state
  end


  def test_bubble_update
    ThreeScale::Analytics::UserTracking.any_instance
        .expects(:track).with('Finished Onboarding Bubble', bubble: 'api')

    @onboarding.bubble_update('api')

    assert_equal 'api_done', @onboarding.bubble_api_state
  end


  def test_bubbles
    assert_equal %I[api metric mapping limit deployment], @onboarding.bubbles

    @onboarding.bubble_api_state = 'api_done'
    assert_equal %I[metric mapping limit deployment], @onboarding.bubbles

    @onboarding.bubble_metric_state = 'metric_done'
    assert_equal %I[mapping limit deployment], @onboarding.bubbles

    @onboarding.bubble_mapping_state = 'mapping_done'
    assert_equal %I[limit deployment], @onboarding.bubbles

    @onboarding.bubble_limit_state = 'limit_done'
    assert_equal %I[deployment], @onboarding.bubbles

    @onboarding.bubble_deployment_state = 'deployment_done'
    assert_equal %I[], @onboarding.bubbles
  end


  def test_process_finished?
    refute @onboarding.process_finished?

    Onboarding::BUBBLES.each do |name|
      @onboarding.public_send "bubble_#{name}_state=", "#{name}_done"
    end

    assert @onboarding.process_finished?
  end

end
