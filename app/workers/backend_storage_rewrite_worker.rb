# frozen_string_literal: true

class BackendStorageRewriteWorker
  include Sidekiq::Job
  sidekiq_options queue: :low

  def perform(class_name, ids)
    Backend::StorageRewrite::Processor.new.rewrite(class_name: class_name, ids: ids)
  end
end
