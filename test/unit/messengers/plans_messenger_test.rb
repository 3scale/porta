require 'test_helper'

class PlansMessengerTest < ActiveSupport::TestCase

  setup do
    Logic::RollingUpdates.expects(skipped?: true).at_least_once
  end

  test '#plan_change_request' do

    cinstance = FactoryGirl.create(:cinstance)
    plan = FactoryGirl.create(:account_plan)
    PlansMessenger.plan_change_request(cinstance, plan).deliver

    email = ActionMailer::Base.deliveries.last
    assert_match('/buyers/applications/', email.body.to_s)
  end
end
