# frozen_string_literal: true

namespace :backend_api do
  desc 'Destroy all orphan backend apis that does not belongs to any service when api_as_product is disabled'
  task :destroy_orphans => :environment do
    BackendApi.orphans.find_each { |backend_api| DeleteObjectHierarchyWorker.perform_later(backend_api) unless backend_api.account.provider_can_use?(:api_as_product) }
  end
end
