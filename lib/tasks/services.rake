# frozen_string_literal: true

namespace :services do
  desc 'Create test contract for each existing service'
  task :create_test_contracts => :environment do
    Service.all.each(&:create_test_contract)
  end

  task :destroy_marked_as_deleted => :environment do
    DestroyAllDeletedObjectsWorker.perform_async(Service.to_s)
  end
end
