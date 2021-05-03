# frozen_string_literal: true

require 'benchmark'
require 'progress_counter'

namespace :services do
  desc 'Create test contract for each existing service'
  task :create_test_contracts => :environment do
    Service.all.each(&:create_test_contract)
  end

  task :destroy_marked_as_deleted => :environment do
    DestroyAllDeletedObjectsWorker.perform_later(Service.to_s)
  end

  desc 'Destroy a service in the Background as long as the provider has at least 1 more service. Whether it is a default one or not'
  task :destroy_service, %i[account_id service_id] => [:environment] do |_task, args|
    account = Account.providers.find(args[:account_id])
    service_id = args[:service_id]
    service = account.services.find(service_id) # So it will raise an error if this service does not belong to this account :)
    if service.default?
      new_default_service = account.services.where.not(id: service_id).first! # It will raise an error if it does not have another service
      new_default_service.send(:make_default_backend_service)
    end
    service.reload.mark_as_deleted!
  end

  desc 'Create default proxy of a service'
  task :create_default_proxy => :environment do
    CreateDefaultProxyWorker::BatchEnqueueWorker.perform_later
  end
end
