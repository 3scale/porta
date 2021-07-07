# frozen_string_literal: true

module CronJob
  class Worker < ApplicationJob

    def perform(args)
      task = ThreeScale::Jobs::Task.deserialize(args)
      task.run
    rescue StandardError => exception
      System::ErrorReporting.report_error(exception,
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
