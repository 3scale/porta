module UsesSidekiqAdapter
  extend ActiveSupport::Concern

  included do
    setup :switch_to_sidekiq_adapter
    teardown :restore_queue_adapter
  end

  private

  def switch_to_sidekiq_adapter
    @original_queue_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :sidekiq
  end

  def restore_queue_adapter
    ActiveJob::Base.queue_adapter = @original_queue_adapter
  end
end
