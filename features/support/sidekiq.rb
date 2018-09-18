# frozen_string_literal: true

require 'sidekiq/testing'

Sidekiq::Testing.inline!

module Sidekiq
  class Testing
    class << self
      def drain_batches
        batches.each do |batch_id|
          batch = Sidekiq::Batch.new(batch_id)
          status = Sidekiq::Batch::Status.new(batch_id)
          batch.callbacks.fetch('complete', []).each do |complete_callback|
            complete_callback.each do |type, options|
              type.constantize.new.on_complete(status, options)
            end
          end
        end
      end

      delegate :redis, to: 'System'

      def batches
        redis.zrange 'batches', 0, batch_count
      end

      def batch_count
        redis.zcount 'batches', '-inf', '+inf'
      end
    end
  end
end
