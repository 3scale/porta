# frozen_string_literal: true

require 'three_scale/sidekiq_batch_cleanup_service'

namespace :sidekiq do
  desc 'cleanup BID-* keys from sidekiq-batch, specify the max age in seconds as an argument'
  task :cleanup_batches, [:max_age_seconds] => :environment do |task, args|
    params = args[:max_age_seconds] ? { max_age_seconds: Integer(args[:max_age_seconds]) } : {}

    ThreeScale::SidekiqBatchCleanupService.call(**params)
  end
end
