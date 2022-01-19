# frozen_string_literal: true


# SphinxIndexationWorker updates sphinx index for the provided model.
# It is enqueued when:
# - An indexed model is created and updated
# - Account is handled by SphinxAccountIndexationWorker
# fixme: destroy doesn't remove indexes due to disabled callbacks in config/initializers/sphinx.rb
class SphinxIndexationWorker < ApplicationJob

  rescue_from(ActiveJob::DeserializationError) do |exception|
    Rails.logger.info "SphinxIndexationWorker#perform raised #{exception.class} with message #{exception.message}"
  end

  def perform(model)
    callback = ThinkingSphinx::RealTime.callback_for(model.class.name.underscore)
    callback&.after_commit model
  end

  private

  def indices(model)
    # this is how indexes are filtered by ThinkingSphinx::ActiveRecord::Callbacks::DeleteCallbacks#indices
    ThinkingSphinx::Configuration.instance.index_set_class.new(
      :classes => [model.class]
    ).to_a
  end
end
