# frozen_string_literal: true

# SphinxIndexationWorker updates sphinx index for the provided model.
# It is enqueued when:
# - An indexed model is created, updated or deleted
# - Account is handled by SphinxAccountIndexationWorker
class SphinxIndexationWorker < ApplicationJob

  rescue_from(ActiveJob::DeserializationError) do |exception|
    Rails.logger.info "SphinxIndexationWorker#perform raised #{exception.class} with message #{exception.message}"
  end

  rescue_from(ThinkingSphinx::SphinxError, ThinkingSphinx::QueryError) do |exception|
    ThinkingSphinx::Connection.clear if exception.message.include?("unknown column")
    raise
  end

  def perform(model, id)
    instance = model.find_by(model.primary_key => id)

    if instance
      reindex(instance)
    else
      delete_from_index(model, id)
    end
  end

  protected

  def reindex(instance)
    ThinkingSphinx::Processor.new(instance: instance).upsert
  end

  def delete_from_index(model, *ids)
    ids.each do |id|
      ThinkingSphinx::Processor.new(model: model, id: id).delete
    end
  end
end
