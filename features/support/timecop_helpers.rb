# frozen_string_literal: true

After do
  Timecop.return
end

module TimecopHelpers
  def time_machine(till)
    Timecop.freeze(Time.zone.now)

    while Time.zone.now < till
      Timecop.freeze(1.day.from_now)
      run(ThreeScale::Jobs::MONTH) if Time.zone.now == Time.zone.now.beginning_of_month
      run(ThreeScale::Jobs::WEEK) if Time.zone.now == Time.zone.now.beginning_of_week
      run(ThreeScale::Jobs::DAILY)
      run(ThreeScale::Jobs::BILLING)
    end
    Timecop.travel(till)
  rescue
    Timecop.return
    raise
  end

  private

  def run(tasks)
    Sidekiq::Testing.inline! do
      tasks.each do |task|
        Rails.logger.info "(#{Time.zone.now}) - CRON is running task '#{task}'"
        begin
          binding.eval(task)
        rescue
          puts "Problem running: #{task}"
          raise
        end
      end

      Sidekiq::Testing.drain_batches
    end
  end
end

# After do
#   Timecop.return
# end

# module TimecopHelpers
#   def time_machine(till)
#     time_zone_now = Time.zone.now
#     Timecop.freeze(time_zone_now)

#     while time_zone_now < till
#       Timecop.freeze(1.day.from_now)
#       run(ThreeScale::Jobs::MONTH) if time_zone_now == time_zone_now.beginning_of_month
#       run(ThreeScale::Jobs::WEEK) if time_zone_now == time_zone_now.beginning_of_week
#       run(ThreeScale::Jobs::DAILY)
#       run(ThreeScale::Jobs::BILLING)
#     end
#     Timecop.travel(till)
#   rescue StandardError
#     Timecop.return
#     raise
#   end

#   private

#   def run(tasks)
#     Sidekiq::Testing.inline! do
#       tasks.each do |task|
#         Rails.logger.info "(#{Time.zone.now}) - CRON is running task '#{task}'"
#         begin
#           binding.eval(task)
#         rescue
#           puts "Problem running: #{task}"
#           raise
#         end
#       end

#       Sidekiq::Testing.drain_batches
#     end
#   end
# end
