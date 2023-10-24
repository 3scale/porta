# frozen_string_literal: true

require 'sidekiq/testing'
require 'sidekiq/lock/testing/inline'

# Turn off Sidekiq logging which pollutes the CI logs
Sidekiq.configure_client do |config|
  config.logger = Sidekiq::Logger.new(nil, level: Logger::FATAL)
end

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
      ::Sidekiq::Worker.drain_all
    end

    def with_sidekiq
      ::Sidekiq::Testing.inline! do
        yield
      end
    end
  end
end

ActiveSupport::TestCase.send(:include, TestHelpers::Sidekiq)
