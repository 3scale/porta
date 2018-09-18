# frozen_string_literal: true

module ThreeScale
  module SidekiqRetrySupport
    module Worker
      extend ActiveSupport::Concern

      included do
        attr_writer :retry_attempt

        def self.retry_limit
          retry_option = get_sidekiq_options['retry']

          case retry_option
          when Integer
            retry_option
          when true
            Sidekiq::JobRetry::DEFAULT_MAX_RETRY_ATTEMPTS
          else
            0
          end
        end
      end

      delegate :retry_limit, to: 'self.class'

      def retry_attempt
        @retry_attempt || 0
      end

      def last_attempt?
        retry_attempt.to_i >= retry_limit
      end

      def with_retry_count
        logger.info { "Running #{retry_identifier} (#{retry_attempt}/#{retry_limit})" }

        yield
      rescue => exception
        logger.info { "#{retry_identifier} attempt ##{retry_attempt} failed with #{exception}" }

        logger.info { "Retrying #{retry_identifier}" } unless last_attempt?
        raise exception
      end

      def retry_identifier
        "#{self.class.name}-#{jid}"
      end
    end

    class Middleware
      def call(worker, msg, *)
        worker.retry_attempt = (msg['retry_count'] || -1) + 1 if worker.respond_to?(:retry_attempt)
        yield
      end
    end
  end
end
