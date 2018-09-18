# frozen_string_literal: true

class BackendProviderSyncWorker
  include Sidekiq::Worker

  def self.enqueue(provider_id)
    perform_async(provider_id)
  end

  def perform(provider_id)
    return unless (provider = Account.providers_with_master.find_by(id: provider_id))
    Backend::StorageSync.new(provider).sync_provider
  end
end
