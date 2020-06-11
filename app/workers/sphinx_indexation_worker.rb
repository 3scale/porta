# frozen_string_literal: true


# SphinxIndexationWorker updates sphinx index for the provided model.
# It is enqueued when:
# - Account gets created, updated (deletion is done automatically as per https://freelancing-gods.com/thinking-sphinx/v3/real_time.html
# - User gets created, updated, deleted
# - Cinstance gets created, updated, deleted
class SphinxIndexationWorker < ApplicationJob

  rescue_from(ActiveJob::DeserializationError) do |exception|
    Rails.logger.info "SphinxIndexationWorker#perform raised #{exception.class} with message #{exception.message}"
  end

  def perform(model)
    callback = ThinkingSphinx::RealTime.callback_for(model.class.name.underscore)
    callback&.after_commit model
  end
end
