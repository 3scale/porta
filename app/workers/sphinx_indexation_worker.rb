# frozen_string_literal: true


# SphinxIndexationWorker updates sphinx index for the provided model.
# It is enqueued when:
# - An indexed model is created and updated
# - Account is handled by SphinxAccountIndexationWorker
# - Deletion is handled by callback registration in model
class SphinxIndexationWorker < ApplicationJob

  rescue_from(ActiveJob::DeserializationError) do |exception|
    Rails.logger.info "SphinxIndexationWorker#perform raised #{exception.class} with message #{exception.message}"
  end

  def perform(instance)
    # some indices are defined on model#base_class (*Plan) some on model itself (CMS::Page)
    callback = ThinkingSphinx::RealTime.callback_for(index_for(instance).model.name.underscore)
    callback&.after_commit instance
  end

  private

  def indices(instance)
    # this is how indexes are filtered by ThinkingSphinx::ActiveRecord::Callbacks::DeleteCallbacks#indices
    ThinkingSphinx::Configuration.instance.index_set_class.new(
      :instances => [instance], :classes => [instance.class]
    ).to_a
  end

  def index_for(instance)
    for_instance = indices(instance)
    if for_instance.size == 1
      for_instance.first
    else
      Rails.logger.error "Found #{for_instance.size} indices for model #{instance.class}, expected 1"
      nil
    end
  end
end
