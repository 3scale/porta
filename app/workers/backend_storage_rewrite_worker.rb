class BackendStorageRewriteWorker
  include Sidekiq::Worker
  sidekiq_options queue: :low

  def self.enqueue_all(providers)
    batch = Sidekiq::Batch.new
    batch.description = 'Rewriting Backend Storage'

    providers.select(:id).find_in_batches do |group|
      batch.jobs do
        group.each do |provider|
          perform_async(provider.id)
        end
      end
    end
  end

  def self.enqueue(provider_id)
    perform_async(provider_id)
  end

  def perform(provider_id)
    provider = Provider.find(provider_id)
    Backend::StorageRewrite.rewrite_provider(provider)
  end
end
