require 'test_helper'

class PlansMessengerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    Logic::RollingUpdates.expects(skipped?: true).at_least_once
  end

  test '#plan_change_request_made' do
    cinstance = FactoryBot.create(:cinstance)
    plan = FactoryBot.create(:account_plan)
    perform_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
      PlansMessenger.plan_change_request_made(cinstance, plan).deliver
    end

    email = ActionMailer::Base.deliveries.last
    assert_includes email.body.to_s, cinstance.name
    assert_includes email.body.to_s, plan.name
  end
end
