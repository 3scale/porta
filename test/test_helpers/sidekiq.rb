# frozen_string_literal: true

require 'sidekiq/testing'
require 'sidekiq/lock/testing/inline'

# Turn off Sidekiq logging which pollutes the CI logs
Sidekiq::Logging.logger = nil
module TestHelpers
  module Sidekiq
    def self.included(base)
      base.setup do
        ::Sidekiq::Worker.clear_all
      end

      base.teardown do
        ::Sidekiq::Worker.clear_all
      end
    end

    def drain_all_sidekiq_jobs
      ThinkingSphinx::Test.rt_run do
        ::Sidekiq::Worker.drain_all
      end
    end

    def with_sidekiq
      ::SphinxIndexationWorker.stubs(:perform_later)

      ::Sidekiq::Testing.inline! do
        yield
      end
    ensure
      ::SphinxIndexationWorker.unstub(:perform_later)
    end
  end
end

ActiveSupport::TestCase.send(:include, TestHelpers::Sidekiq)
