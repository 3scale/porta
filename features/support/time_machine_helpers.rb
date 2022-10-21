# frozen_string_literal: true

module TimeMachineHelpers

  # This method no only moves time to a particular point, it also simulates all scheduled events in the middle.
  # This is useful for testing cases like removing a user, when the user is not really removed until a month later by
  # a job that takes care of it. This kind of behavior can be tested this way:
  #
  # 1. Remove the user
  # 2. time_machine 1 month from now
  # 3. Assert the user has been effectively removed
  def time_machine(till)
    freeze_time

    while Time.zone.now < till
      travel_to(1.day.from_now)
      run_jobs
    end
    travel_to(till)
  rescue StandardError
    travel_back
    raise
  end

  private

  def run_jobs
    now = Time.zone.now
    run(ThreeScale::Jobs::MONTH) if now == now.beginning_of_month
    run(ThreeScale::Jobs::WEEK) if now == now.beginning_of_week
    run(ThreeScale::Jobs::DAILY)
    run(ThreeScale::Jobs::BILLING)
  end

  def run(tasks)
    Sidekiq::Testing.inline! do
      tasks.each do |task|
        Rails.logger.info "(#{Time.zone.now}) - CRON is running task '#{task}'"
        begin
          task.run
        rescue StandardError
          puts "Problem running: #{task}"
          raise
        end
      end

      Sidekiq::Testing.drain_batches
    end
  end
end
