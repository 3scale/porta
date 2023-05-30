# frozen_string_literal: true

module ThreadHelper
  # This allows some part of the code to run in another Thread
  # The issue is that Rails allocate a new connection on the new Thread
  # So the global wrapping transaction is obviously not seen by this new Thread
  # When Rails rolls back the global transaction, this thread has already
  # committed changes to the DB.
  def within_async_thread(*args)
    Thread.new(*args) do |*arguments|
      ActiveRecord::Base.transaction(requires_new: true) do
        yield *arguments
        raise ActiveRecord::Rollback
      end
    end
  end

  def within_thread(*args, &block)
    within_async_thread(*args, &block).join
  end
end

ActiveSupport::TestCase.class_eval do
  include ThreadHelper
end
