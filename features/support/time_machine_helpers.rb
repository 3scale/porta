# frozen_string_literal: true

module TimeMachineHelpers
  def time_machine(till)
    travel_to(Time.zone.now)

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
    run(ThreeScale::Jobs::MONTH) if Time.zone.now == Time.zone.now.beginning_of_month
    run(ThreeScale::Jobs::WEEK) if Time.zone.now == Time.zone.now.beginning_of_week
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
