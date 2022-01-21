require 'active_job/test_helper'
require 'active_job/queue_adapters/test_adapter'

# TODO: Remove this Monkey patch after we move to Rails 5.2
# This is used to ensure that we run only a specific job in a Test.
# It was extracted from
# https://github.com/rails/rails/blob/fc5dd0b85189811062c85520fd70de8389b55aeb/activejob/lib/active_job/test_helper.rb#L368
module ActiveJob
  module QueueAdapters
    class TestAdapter
      attr_accessor(:perform_enqueued_jobs, :perform_enqueued_at_jobs, :filter, :reject, :queue, :at)
      attr_writer(:enqueued_jobs, :performed_jobs)

      def enqueued_jobs
        @enqueued_jobs ||= []
      end

      def performed_jobs
        @performed_jobs ||= []
      end

      def enqueue(job) #:nodoc:
        return if filtered?(job)

        job_data = job_to_hash(job)
        perform_or_enqueue(perform_enqueued_jobs, job, job_data)
      end

      def enqueue_at(job, timestamp) #:nodoc:
        return if filtered?(job)

        job_data = job_to_hash(job, at: timestamp)
        perform_or_enqueue(perform_enqueued_at_jobs, job, job_data)
      end

      private

      def job_to_hash(job, extras = {})
        { job: job.class, args: job.serialize.fetch("arguments"), queue: job.queue_name }.merge!(extras)
      end

      def perform_or_enqueue(perform, job, job_data)
        if perform
          performed_jobs << job_data
          Base.execute job.serialize
        else
          enqueued_jobs << job_data
        end
      end

      def filtered?(job)
        filtered_queue?(job) || filtered_job_class?(job) || filtered_time?(job)
      end

      def filtered_time?(job)
        job.scheduled_at > at.to_f if at && job.scheduled_at
      end

      def filtered_queue?(job)
        if queue
          job.queue_name != queue.to_s
        end
      end

      def filtered_job_class?(job)
        if filter
          !filter_as_proc(filter).call(job)
        elsif reject
          filter_as_proc(reject).call(job)
        end
      end

      def filter_as_proc(filter)
        return filter if filter.is_a?(Proc)

        ->(job) { Array(filter).include?(job.class) }
      end
    end
  end

  module TestHelper
    class << self
      def included(base)
        base.class_eval do
          def perform_enqueued_jobs(only: nil, except: nil)
            raise ArgumentError, "Cannot specify both `:only` and `:except` options." if only && except
            old_perform_enqueued_jobs = queue_adapter.perform_enqueued_jobs
            old_perform_enqueued_at_jobs = queue_adapter.perform_enqueued_at_jobs
            old_filter = queue_adapter.filter
            old_reject = queue_adapter.reject

            begin
              queue_adapter.perform_enqueued_jobs = true
              queue_adapter.perform_enqueued_at_jobs = true
              queue_adapter.filter = only
              queue_adapter.reject = except
              yield
            ensure
              queue_adapter.perform_enqueued_jobs = old_perform_enqueued_jobs
              queue_adapter.perform_enqueued_at_jobs = old_perform_enqueued_at_jobs
              queue_adapter.filter = old_filter
              queue_adapter.reject = old_reject
            end
          end
        end
      end
    end
  end
end
