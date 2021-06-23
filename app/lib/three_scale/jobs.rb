# frozen_string_literal: true

# Periodic tasks code are extracted to constants so that
# it can be easily run by tests.
#
module ThreeScale
  module Jobs

    class Task
      def initialize(object, method, *args)
        @object = object
        @method = method
        @arguments = args
      end

      def name
        [@object, @method, @arguments].join('_').tr('():.', '_')
      end

      def run
        @object.public_send(@method, *@arguments)
      end

      def to_s
        "#{self.class} with: #{init_args.inspect}"
      end

      def self.map(tasks)
        tasks.map {|task_args| new(*task_args)}
      end

      def serialize
        {
          klass: self.class.to_s,
          init_args: init_args
        }
      end

      def self.deserialize(hash)
        hash['klass'].constantize.new(*YAML.load(hash['init_args']))  # rubocop:disable Security/YAMLLoad
      end

      protected

      def init_args
        YAML.dump([@object, @method, @arguments])
      end
    end

    class RakeTask < Task

      def initialize(task_name) # rubocop:disable Lint/MissingSuper
        @task_name = task_name
      end

      def run
        # Do not reload the tasks if it is already loaded
        Rails.application.load_tasks unless ::Rake.application
        task = ::Rake.application[@task_name]
        return unless task

        task.invoke
      ensure
        # We need to reenable the task as the instance is shared among workers
        task&.reenable
      end

      def init_args
        [@task_name]
      end
    end

    MONTH = [].freeze

    WEEK = Task.map([
                      [Pdf::Dispatch, :weekly],
                      [JanitorWorker, :perform_async],
                      [SuspendInactiveAccountsWorker, :perform_async],
                      [StaleAccountWorker, :perform_async]
                    ]).freeze

    DAILY = Task.map([
                       [FindAndDeleteScheduledAccountsWorker, :perform_async],
                       [SegmentDeleteUsersWorker, :perform_later],
                       [Audited.audit_class, :delete_old],
                       [LogEntry, :delete_old],
                       [Cinstance, :notify_about_expired_trial_periods],
                       [Pdf::Dispatch, :daily],
                       [DeleteProvidedAccessTokensWorker, :perform_async],
                       [DestroyAllDeletedObjectsWorker, :perform_later, 'Service'],
                       [CreateDefaultProxyWorker::BatchEnqueueWorker, :perform_later]
                     ]).freeze

    BILLING = Task.map([
                         [Finance::BillingStrategy, :daily_canaries],
                         [Finance::BillingStrategy, :daily_rest]
                       ]).freeze

    HOUR = Task.map([
                      [Rails, :env]
                    ]).freeze # just a fake job to ensure cron works

    SPHINX_INDEX_ALL = [RakeTask.new('sphinx:enqueue')].freeze

    CUSTOM = [].freeze

  end
end
