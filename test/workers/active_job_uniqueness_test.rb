require 'test_helper'

class ActiveJobUniquenessTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include ActiveJobUniquenessTestHelper

  setup do
    JobUniquenessTestWorker.run_counter = 0
  end

  teardown do
    active_job_uniqueness_test_mode!
  end

  test "unique jobs until executed" do
    active_job_uniqueness_enable!
    locks, unlocks, conflicts, logs = 0, 0, 0, 0

    ActiveSupport::Notifications.subscribe('lock.active_job_uniqueness') do
      locks += 1
    end

    ActiveSupport::Notifications.subscribe('unlock.active_job_uniqueness') do
      unlocks += 1
    end

    ActiveSupport::Notifications.subscribe('conflict.active_job_uniqueness') do
      conflicts += 1
    end

    Rails.logger.stubs(:info).with do |msg|
      logs += 1 if msg == "Another job is already scheduled for: ActiveJobUniquenessTest::JobUniquenessTestWorker []"
      true
    end

    5.times do
      JobUniquenessTestWorker.perform_later
    end
    assert_enqueued_jobs 1, only: JobUniquenessTestWorker
    # In Rails 6.0 we can just call #perform_enqueued_jobs
    enqueued_jobs.each { |job_data| instantiate_job(job_data).perform_now }

    assert_equal 1, JobUniquenessTestWorker.run_counter
    assert_equal 1, locks
    assert_equal 1, unlocks
    assert_equal 4, conflicts

    perform_enqueued_jobs do
      JobUniquenessTestWorker.perform_later
    end

    assert_equal 2, JobUniquenessTestWorker.run_counter
    assert_equal 2, locks
    assert_equal 2, unlocks
    assert_equal 4, conflicts
    assert_equal 4, logs
  end

  class JobUniquenessTestWorker < ApplicationJob
    class << self
      attr_accessor :run_counter
    end

    unique :until_executed

    def perform(*)
      self.class.run_counter += 1
    end
  end
end
