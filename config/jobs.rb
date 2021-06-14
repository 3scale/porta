# Periodic tasks code are extracted to constants so that
# it can be easily run by tests.
#
module ThreeScale
  module Jobs
    # Using this needs to be run inside of instance_exec
    # Define those methods: `runner`
    JOB_PROC = proc do |task|
      if task.respond_to? :each_pair
        # then specifies whenever command and task to run
        task.each_pair do |command, args|
          send command, args
        end
        # else if it is like string, run it as runner
      elsif task.respond_to? :to_str
        runner "ThreeScale::Jobs.run(#{task.inspect}) { #{task} }"
      end
    end

    MONTH = [].freeze

    WEEK = %w[
      Pdf::Dispatch.weekly
      JanitorWorker.perform_async
      SuspendInactiveAccountsWorker.perform_async
      StaleAccountWorker.perform_async
    ].freeze

    DAILY = %w[
      FindAndDeleteScheduledAccountsWorker.perform_async
      SegmentDeleteUsersWorker.perform_later
      Audited.audit_class.delete_old
      LogEntry.delete_old
      Cinstance.notify_about_expired_trial_periods
      Pdf::Dispatch.daily
      DeleteProvidedAccessTokensWorker.perform_async
      DestroyAllDeletedObjectsWorker.perform_later(Service.to_s)
      CreateDefaultProxyWorker::BatchEnqueueWorker.perform_later
    ].freeze

    BILLING = %w[
      Finance::BillingStrategy.daily_canaries
      Finance::BillingStrategy.daily_rest
    ].freeze

    HOUR = %w[Rails.env].freeze # just a fake job to ensure cron works

    SPHINX_INDEX_ALL = [{ 'rake' => 'sphinx:enqueue' }].freeze

    CUSTOM = {
    }.freeze

    def self.run(task = nil)
      yield if block_given?
    rescue => error
      System::ErrorReporting.report_error(error,
                                          component: 'job',
                                          action:     task)
      raise
    end
  end
end
