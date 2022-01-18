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
    rt_callback = ThinkingSphinx::RealTime.callback_for(model.class.name.underscore)

    # use delete callback only if real time callbacks are also enabled
    if rt_callback.send(:callbacks_enabled?) && model.try(:will_be_deleted?)
      ThinkingSphinx::Callbacks.resume do
        ThinkingSphinx::ActiveRecord::Callbacks::DeleteCallbacks.after_destroy(model)
      end
    else
      rt_callback&.after_commit(model)
    end
  end
end
