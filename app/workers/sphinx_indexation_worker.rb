# frozen_string_literal: true

# SphinxIndexationWorker updates sphinx index for the provided model.
# It is enqueued when:
# - An indexed model is created, updated or deleted
# - Account is handled by SphinxAccountIndexationWorker
class SphinxIndexationWorker < ApplicationJob

  rescue_from(ActiveJob::DeserializationError) do |exception|
    Rails.logger.info "SphinxIndexationWorker#perform raised #{exception.class} with message #{exception.message}"
  end

  def perform(model, id)
    ThinkingSphinx::Processor.new(model: model, id: id).stage
  end
end
