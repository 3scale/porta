require 'test_helper'

class ActivationReminderWorkerTest < ActiveSupport::TestCase

  setup do
    @user = FactoryBot.create(:simple_user, state: "pending")
  end

  should "send reminder if user is pending" do
    ProviderUserMailer.expects(:activation_reminder).returns(mock('mail', deliver_now: true)).once
    ActivationReminderWorker.new.perform(@user.id)
  end

  should "not send reminder if user is active" do
    @user.state = "active"
    @user.save

    ProviderUserMailer.expects(:activation_reminder).never
    ActivationReminderWorker.new.perform(@user.id)
  end

  should "send a reminder 72 hours after signup" do
    Timecop.freeze do
      ActivationReminderWorker.enqueue(@user)
      assert_equal 1, ActivationReminderWorker.jobs.size

      job = ActivationReminderWorker.jobs.first

      assert_equal 3.days.from_now.to_i, Time.zone.at(job['at']).to_i
    end
  end
end
