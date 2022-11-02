# frozen_string_literal: true


# SphinxIndexationWorker updates sphinx index for the provided model.
# It is enqueued when:
# - An indexed model is created, updated or deleted
# - Account is handled by SphinxAccountIndexationWorker
class SphinxIndexationWorker < ApplicationJob

  rescue_from(ActiveJob::DeserializationError) do |exception|
    Rails.logger.info "SphinxIndexationWorker#perform raised #{exception.class} with message #{exception.message}"
  end

  def perform(model, id=nil)
    indices_for_model(model).each do |index|
      instance = index.scope.find_by(model.primary_key => id)

      if instance
        reindex(index, instance)
      else
        delete_from_index(index, id)
      end
    end
  end

  protected

  def indices_for_instance(instance)
    # this is how indexes are filtered by ThinkingSphinx::ActiveRecord::Callbacks::DeleteCallbacks#indices
    ThinkingSphinx::Configuration.instance.index_set_class.new(
      :instances => [instance], :classes => [instance.class]
    ).to_a
  end

  def indices_for_model(model)
    ThinkingSphinx::Configuration.instance.index_set_class.new(classes: [model])
  end

  def reindex(index, instance)
    # some indices are defined on model#base_class (*Plan) some on model itself (CMS::Page)
    callback = ThinkingSphinx::RealTime.callback_for(index.model.name.underscore)
    callback&.after_commit instance
  end

  def delete_from_index(index, *ids)
    # This is how deletion is performed by ThinkingSphinx::ActiveRecord::Callbacks::DeleteCallbacks#delete_from_sphinx
    ThinkingSphinx::Deletion.perform index, ids
  end
end
