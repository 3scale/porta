# frozen_string_literal: true

namespace :sidekiq do
  desc 'cleanup BID-* keys from sidekiq-batch'
  task cleanup_batches: :environment do
    Rails.logger.info "Cleaning up BID-* keys from sidekiq-batch..."
    SidekiqBatchCleanupService.new.call
  end
end
