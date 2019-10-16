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

  desc 'Migrate proxies api_backend to backend api configs.'
  task create_backend_apis: :environment do
    puts 'Migrating proxies api_backend to backend api configs...'
    duration = Benchmark.measure do
      Service.transaction do
        progress = ProgressCounter.new(Service.count)
        Service.includes(:backend_api_configs).find_each(batch_size: 100) do |service|
          progress.call do
            next if service.backend_api_configs.any?

            service_name = service.name
            backend_api = service.account.backend_apis.create(
              system_name: service.system_name,
              name: "#{service_name} Backend",
              description: "Backend of #{service_name}",
              private_endpoint: service.proxy&.[]('api_backend')
            )

            service.backend_api_configs.create(backend_api: backend_api, path: '/')
          end
        end
      end
    end
    puts "Finished in #{format('%.1fs', duration.real)}\n\t"
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
