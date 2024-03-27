# frozen_string_literal: true

require 'test_helper'

class ThreeScale::SidekiqRetrySupportTest < ActiveSupport::TestCase
  class WorkerTest < ActiveSupport::TestCase
    TestWorker = Class.new do
      include Sidekiq::Job
      include ThreeScale::SidekiqRetrySupport::Worker
    end

    setup do
      @worker = TestWorker.new
    end

    attr_reader :worker

    test 'counts retry attempts' do
      assert_equal 0, worker.retry_attempt
    end

    test 'fetches the retry limit from sidekiq options' do
      assert_equal 25, worker.retry_limit

      other_class = Class.new do
        include Sidekiq::Job
        include ThreeScale::SidekiqRetrySupport::Worker

        sidekiq_options retry: 10
      end

      assert_equal 10, other_class.retry_limit
    end

    test '#last_attempt?' do
      refute worker.last_attempt?
      worker.retry_attempt = 25
      assert worker.last_attempt?
    end

    test 'retry log' do
      TestException = Class.new(StandardError)

      worker.stubs(retry_identifier: 'my-job')

      worker.logger.expects(:info).with('Running my-job (0/25)')
      worker.logger.expects(:info).with('my-job attempt #0 failed with error message')
      worker.logger.expects(:info).with('Retrying my-job')

      assert_raises(TestException) do
        worker.with_retry_log { raise TestException, 'error message' }
      end

      worker.retry_attempt = 25

      worker.logger.expects(:info).with('Running my-job (25/25)')
      worker.logger.expects(:info).with('my-job attempt #25 failed with error message')

      assert_raises(TestException) do
        worker.with_retry_log { raise TestException, 'error message' }
      end
    end

    test 'retry identifier' do
      worker.stubs(jid: '1234')
      assert_equal 'ThreeScale::SidekiqRetrySupportTest::WorkerTest::TestWorker-1234', worker.retry_identifier
    end
  end
end
