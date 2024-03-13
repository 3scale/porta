# frozen_string_literal: true

require 'sidekiq/testing'
require 'sidekiq/batch'

# Turn off Sidekiq logging which pollutes the CI logs
Sidekiq.configure_client do |config|
  config.logger = Sidekiq::Logger.new(nil, level: Logger::FATAL)
end

Sidekiq::Testing.inline!

module Sidekiq
  class Testing
    class << self
      def drain_batches
        batches.each do |batch_id|
          batch = Sidekiq::Batch.new(batch_id)
          status = Sidekiq::Batch::Status.new(batch_id)

          handle_callbacks(batch, batch_id, status)
        end
      end

      delegate :redis, to: 'System'

      def batches
        sidekiq_pro_batches.presence || sidekiq_batch_batches
      end

      def sidekiq_pro_batches
        redis.zrange 'batches', 0, batch_count
      end

      def sidekiq_batch_batches
        redis.keys('BID-*-callbacks-*').map do |key|
          key.scan(/^BID-(.+?)-callbacks-\w+$/)
        end.flatten
      end

      def batch_count
        redis.zcount 'batches', '-inf', '+inf'
      end

      private

      def handle_callbacks(_batch, batch_id, _status)
        Sidekiq::Batch.enqueue_callbacks(:complete, batch_id)
        Sidekiq::Batch.enqueue_callbacks(:success, batch_id)
      end
    end

    server_middleware do |chain|
      chain.add Sidekiq::Batch::Middleware::ServerMiddleware
    end
  end
end
