# frozen_string_literal: true

module CronJob
  class Worker
    include Sidekiq::Worker

    def perform(task)
      Rails.logger.debug("Executing cron task #{task}")
      instance_exec(task, &ThreeScale::Jobs::JOB_PROC)
    end

    def rake(task)
      system('rake', task)
    end

    def runner(command)
      system('rails', 'runner', command)
    end
  end

  class Enqueuer
    include Sidekiq::Worker

    def perform(constant_name)
      enqueue_tasks(constant_name) do |task|
        Rails.logger.debug("Enqueueing cron task [#{constant_name}] #{task}")
        CronJob::Worker.perform_async(task)
      end
    end

    protected

    def enqueue_tasks(name, &block)
      ThreeScale::Jobs.const_get(name).each(&block)
    end
  end
end
