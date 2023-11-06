# frozen_string_literal: true

class BackendStorageRewriteWorker
  include Sidekiq::Worker
  sidekiq_options queue: :low

  ENQUEUER = ->(class_name, ids) { BackendStorageRewriteWorker.perform_async(class_name, ids) }

  # Enqueue async processing for all providers
  def self.enqueue_all
    Backend::StorageRewrite::AsyncProcessor.new(enqueuer: ENQUEUER).rewrite_all
  end

  # Enqueue async processing for a single provider
  def self.enqueue(provider_id)
    Backend::StorageRewrite::AsyncProcessor.new(enqueuer: ENQUEUER).rewrite_provider(provider_id)
  end

  # The arguments of the worker are: the class name of the collection, and the array of IDs of objects of this class
  # It should not exceed the BATCH_SIZE defined in AsyncProcessor
  # All objects in a batch will belong to the same provider (tenant)
  def perform(class_name, ids)
    Backend::StorageRewrite::Processor.new.rewrite(class_name: class_name, ids: ids)
  end
end
