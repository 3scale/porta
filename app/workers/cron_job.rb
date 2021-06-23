# frozen_string_literal: true

module CronJob
  class Worker < ApplicationJob

    def perform(hash)
      task = ThreeScale::Jobs::Task.deserialize(hash)
      task.run
    rescue => error
      System::ErrorReporting.report_error(error,
                                          component: 'job',
                                          action: task)
      raise
    end
  end

  class Enqueuer < ApplicationJob
    def perform(constant_name)
      enqueue_tasks(constant_name) do |task|
        Rails.logger.debug("Enqueueing cron task [#{constant_name}] #{task}")
        CronJob::Worker.perform_later(task.serialize)
      end
    end

    protected

    def enqueue_tasks(name, &block)
      ThreeScale::Jobs.const_get(name).each(&block)
    end
  end
end
