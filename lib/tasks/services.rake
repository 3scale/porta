# frozen_string_literal: true

require 'benchmark'
require 'progress_counter'

namespace :services do
  desc 'Create test contract for each existing service'
  task :create_test_contracts => :environment do
    Service.all.each(&:create_test_contract)
  end

  task :destroy_marked_as_deleted => :environment do
    DestroyAllDeletedObjectsWorker.perform_async(Service.to_s)
  end

  desc 'Update metric owners'
  task update_metric_owners: :environment do
    puts 'Updating metric owners...'
    duration = Benchmark.measure do
      progress = ProgressCounter.new(Metric.count)
      Metric.find_each do |metric|
        metric.update_columns(owner_id: metric.service_id, owner_type: 'Service') unless metric.owner_type?
        progress.call
      end
    end
    puts "Finished in #{format('%.1fs', duration.real)}\n\t"
  end
end
