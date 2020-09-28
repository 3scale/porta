require 'test_helper'

class OnboardingTest < ActiveSupport::TestCase

  def setup
    @onboarding = Onboarding.new
    @onboarding.account_id = 42
    @onboarding.save!
  end

  test 'should initialize with correct initial states' do
    assert_equal 'initial', @onboarding.wizard_state
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

end
