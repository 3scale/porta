# frozen_string_literal: true

namespace :backend_api do
  desc 'Destroy all orphan backend apis that does not belongs to any service when api_as_product is disabled'
  task :destroy_orphans => :environment do
    BackendApi.orphans.joins(:account).select(:id, :account_id).find_each do |backend_api|
      next if backend_api.account.provider_can_use?(:api_as_product)
      DeleteObjectHierarchyWorker.perform_later(backend_api)
    end
  end
end
